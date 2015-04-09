#!/usr/bin/ruby -w

# We can represent a 3x9 grid as three 9-bit numbers (0=blank, 1=present)
#
#  8  7  6  5  4  3  2  1  0
#  8  7  6  5  4  3  2  1  0
#  8  7  6  5  4  3  2  1  0
#
# The constraints are then:
# - each row must have exactly 5 bits set
# - each column must have at least one bit set
#
# If we enumerate all 9-bit patterns with 5 bits set, that is only
# 9C5 = 9!/(5!4!) = 126 patterns.
# So there are "only" 126 ^ 3 patterns to consider, and we can
# efficiently test that at least one bit is set in each column by
# OR'ing them together
#
# Then we can re-arrange into a single 27-bit word as:
#
# 26 25 24 23 22 21 20 19 18
# 17 16 15 14 13 12 11 10  9
#  8  7  6  5  4  3  2  1  0
#
# and therefore each grid pattern is just a Fixnum. The Gridpattern class
# is responsible for calculating and indexing valid grid patterns.
#
# Now, for the purposes of building a book, certain sets of grids are
# interchangeable: we only care about how many items are in each column,
# not their positions. So we make a 'key' which is a nine-digit number
# giving the total number of bits in each column; all grid patterns with the
# same key are interchangeable when assembling a book. e.g.
#
#   X       X   X X X
#       X X   X X X     => "211112322"
#   X X       X X   X
#
# We then treat this string as a base32 number when storing the key.
# This has the convenient property that simply adding the keys together
# counts the number of bits used in each column; a valid book will add
# up to 9AAAAAAAB. (We could actually use base19 or higher; the worst case
# we could see is six tickets each with 3 bits in the same column)

class Gridpattern

  attr_reader :all_patterns, :cats
  def initialize
    @all_patterns = []    # [patt, patt, ...]
    @cats = {}            # category => [patt, patt, ...]
  end

  # Enumerate all valid grid patterns
  #
  # This takes about 20 seconds on a P4 2.8GHz to generate 735,210 grids
  # and put them into 1,554 categories. Not bad for a scripting language :-)

  def generate_grids
    return if @all_patterns.size > 0

    # all 9 bit patterns which have 5 bits set
    patts = []
    (0..4).each do |b1|
      (b1+1..5).each do |b2|
        (b2+1..6).each do |b3|
          (b3+1..7).each do |b4|
            (b4+1..8).each do |b5|
              patts << ((1<<b1)|(1<<b2)|(1<<b3)|(1<<b4)|(1<<b5))
            end
          end
        end
      end
    end
    raise "Sanity error" if patts.size != 126

    # try all combinations of three row patterns
    patts.each do |p1|
      patts.each do |p2|
        pp = p1 | p2
        patts.each do |p3|
          next unless pp | p3 == 0x1ff
          p = ((p1 << 18) | (p2 << 9) | p3)
          @all_patterns << p

          # Now index this pattern by category
          cat = p1.to_s(2).to_i(32) +
                p2.to_s(2).to_i(32) +
                p3.to_s(2).to_i(32)
          @cats[cat] ||= []
          @cats[cat] << p
        end
      end
    end
  end

  def pick_any
    @all_patterns[ rand(@all_patterns.size) ]
  end

  # Convert a grid pattern into its individual rows: returns [int,int,int]
  def self.gridsplit(p)
    [(p >> 18) & 0x1ff, (p >> 9) & 0x1ff, p & 0x1ff]
  end

  # Convert a grid pattern into its category
  def self.gridcat(p)
    ((p >> 18) & 0x1ff).to_s(2).to_i(32) +
    ((p >> 9) & 0x1ff).to_s(2).to_i(32) +
    (p & 0x1ff).to_s(2).to_i(32)
  end
end # class Gridpattern

# A Bookpattern is an array of of 6 compatible grid patterns. They are
# compatible if the there are 9 b8's set, 10 b7's set, 10 b6's set,
# ...10 b1's set, and 11 b0's set. We check this by adding together
# the keys.

class Bookpattern
  attr_reader :gridpatterns
  def initialize(pats = nil)
    @gridpatterns = pats
    check
  end

  TOTAL_BITS = "9AAAAAAAB".to_i(32)   # what the columns add up to

  def check
    tot = 0
    @gridpatterns.each { |gp| tot += Gridpattern.gridcat(gp) }
    raise "Bad book pattern: #{pats.inspect}" unless tot == TOTAL_BITS
  end

  # Make a random Bookpattern. Pass in the Gridpattern object which contains
  # all possible grid patterns, and it will return one random book pattern.
  #
  # We loop around trying to find a valid book. The "2.times" heuristic is
  # to avoid us digging ourselves too deep into a hole if we make a
  # bad choice.

  def self.make_random(gp)
    while true
      p1 = gp.pick_any
      tot1 = Gridpattern.gridcat(p1)
      2.times do
        p2 = gp.pick_any
        tot2 = tot1 + Gridpattern.gridcat(p2)
        2.times do
          p3 = gp.pick_any
          tot3 = tot2 + Gridpattern.gridcat(p3)
          2.times do
            p4 = gp.pick_any
            tot4 = tot3 + Gridpattern.gridcat(p4)
            2.times do
              p5 = gp.pick_any
              tot5 = tot4 + Gridpattern.gridcat(p5)
              remainder = TOTAL_BITS - tot5
              p6a = gp.cats[remainder]   # compatible options for last grid
              next unless p6a
              p6 = p6a[ rand(p6a.size) ]
              next unless tot5 + Gridpattern.gridcat(p6) == TOTAL_BITS  # sanity check
              return Bookpattern.new([p1,p2,p3,p4,p5,p6])
            end
          end
        end
      end
    end
  end
end # class Bookpattern

# A completed grid, represented as [ [val, val, val], [val, val, val], ... ]
# where val is nil for a blank square

class Grid
  def initialize(g = [])
    @g = g
  end

  # add a column of form [val, val, val]
  def add_column(c)
    @g << c
  end

  SEP = "+----" * 9 + "+\n"
  def to_s
    str = SEP.dup
    3.times do |row|
      9.times do |col|
        str << sprintf("| %2s ", @g[col][row])
      end
      str << "|\n" << SEP
    end
    str
  end

  # Raise an exception if ticket violates structure rules
  # (TODO: check values in each column are in correct numeric range)
  def check
    raise "Wrong number of columns (#{@g.size})" if @g.size != 9
    nr = [0, 0, 0]
    @g.each do |c|
      raise "Wrong number of rows (#{c.size})" if c.size != 3
      nc = (0..2).collect { |i| c[i].nil? ? 0 : 1 }
      raise "Empty column" if nc[0]+nc[1]+nc[2] < 1
      max = 0
      (0..2).each do |i|
        nr[i] += nc[i]
        next if c[i].nil?
        raise "Column out of sequence: #{c.inspect}" if c[i] <= max
        max = c[i]
      end
    end
    (0..2).each { |i| raise "Wrong no. items in row (#{nr[i]})" if nr[i] != 5 }
  end
end # class Grid

# A bookset consists of each integer 1 to 90, arranged in groups for
# each column, in randomized order. These can then be consumed into
# grid patterns to make real grids.

class Bookset
  def initialize
    @set = [
      (1..9).to_a, (10..19).to_a, (20..29).to_a, (30..39).to_a, (40..49).to_a,
      (50..59).to_a, (60..69).to_a, (70..79).to_a, (80..90).to_a
    ]
    @set.map! { |s| s.sort_by { rand } }
  end

  # Pick numbers out of this bookset to populate a grid of given pattern
  # (pattern is a 27-bit Fixnum as described earlier)

  def apply_gridpattern(pattern)
    p = Gridpattern.gridsplit(pattern)
    g = Grid.new
    colbit = 0x100
    9.times do |index|
      # pick the right amount of numbers
      pick = []
      p.each do |bitpat|
        next unless (bitpat & colbit) != 0
        val = @set[index].shift
        raise "Out of numbers applying pattern #{p}!" if val.nil?
        pick << val
      end
      pick.sort!
      # put them into the column
      col = p.collect do |bitpat|
        if (bitpat & colbit) != 0
          pick.shift
        else
          nil
        end
      end
      g.add_column(col)
      colbit >>= 1
    end
    g
  end

  def apply_bookpattern(p)
    res = []
    p.gridpatterns.each do |g|
      res << apply_gridpattern(g)
    end
    raise "Not all numbers used!" unless empty?
    res
  end

  def empty?
    @set.flatten.empty?
  end
end # class Bookset

############ Main program #############

begin
  h = nil
  File.open("housie.obj") { |f| puts "Loading grids..."; h = Marshal.load(f) }
rescue Errno::ENOENT, TypeError
  h = Gridpattern.new
  puts "Generating grids (please wait)"
  h.generate_grids
  puts "#{h.all_patterns.size} grids"
  puts "#{h.cats.size} grid groups"
  puts "Saving..."
  File.open("housie.obj","w") { |f| Marshal.dump(h, f) }
end

# Problem 1: generate 10 random tickets

10.times do |i|
  # Generate a single ticket from a random grid pattern
  bs = Bookset.new
  t = bs.apply_gridpattern(h.pick_any)
  t.check
  puts "==== Ticket #{i} ===="
  puts t.to_s
  puts
end

# Problem 2: generate 100 books (takes roughly 6ms per book when
# printing is disabled)

t1 = Time.now
100.times do |i|
  bs = Bookset.new
  tickets = bs.apply_bookpattern(Bookpattern.make_random(h))
  # next # disable printing
  puts "==== Book #{i} ===="
  tickets.each do |t|
    t.check
    puts t.to_s
    puts
  end
end
t2 = Time.now
puts "Time taken to generate books: #{t2-t1}"
