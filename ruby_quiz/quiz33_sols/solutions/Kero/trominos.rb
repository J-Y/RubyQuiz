# 1) There is no regular coverage of trominos over a 2**n square board (3 does
#     not divide 2**n)
# 2) however, tromino's can cover 3/4 of such a board. the factor three has
#    been introduced. Which three quarters? Let me show you:
#
#    +---+         Which in itself is a tromino-shaped area, but twice as big.
#    |   |         You can't miss the factor 2 which also appears in 2**n, so
#    | +-+         this basically gives the algorithm for the solution away.
#    | | |
#    +-+ +-+-+  3) We shall display the board. I'm going to try to use the
#    | |   | |     recursion efficiently and not keep the entire board in
#    | +---+ |     memory.
#    |   |   |
#    +---+---+  4) Line-by-line we see one or two squares of a tromino that we
#                  must know. Three squares, four orientations, twelve ids.

#  F T L J, clockwise numbered :F1 :F2 :F3 etc
# We would have, from the above shape
#  :L => [
#    [ :F2, :F3,   0,   0 ],
#    [ :F1, :L3,   0,   0 ],
#    [ :L3, :L2, :L1, :J1 ],
#    [ :L2, :L1, :J3, :J2 ]
#  ],
# but that's not recursive, so we get (clockwise):
#  :L1 => [:L1, :J1, :J2, :J3],
#  :L2 => [:L3, :L2, :L1, :L2],
#  :L3 => [:F2, :F3, :L3, :F1],
# We're lazy (and we hate typos) so we'll generate this

class Array
  # shift element and append it again, name from CPU registers
  def rotate!()
    push(shift)
  end
  # substitute first occurrence of +orig+
  def sub(orig, replace)
    result = dup
    result[index(orig)] = replace
    result
  end
end

Trominos = [ :J0, :T0, :F0, :L0 ]  # rotating J counterclockwise gives T, F, L
Sub = {}

# Set tromino in 2x2 square, clockwise, using :X0 as 'empty'
# With only these set, the script already works for n==1 :)
a = (0..3).to_a  # clockwise numbering of :J, 0 being 'empty' (excluded square)
Trominos.each { |sym|
  str = (0..3).collect { |i|  ":#{sym}#{a[i]}".sub(/0/, "") }.join(", ")
  Sub[sym] = eval("[#{str}]")
  a.rotate!  # rotate counterclockwise
}

# For all 12 possibilities, set subsquare, clockwise
(0..3).each { |i|
  counter = Trominos[(i+1) % 4]
  sym = Trominos[i]
  clockwise = Trominos[(i+3) % 4]
  first = eval(":#{sym}".sub(/0/, "1"))
  Sub[first] = Sub[counter].sub(counter, first)
  second = eval(":#{sym}".sub(/0/, "2"))
  Sub[second] = Sub[sym].sub(sym, second)
  third = eval(":#{sym}".sub(/0/, "3"))
  Sub[third] = Sub[clockwise].sub(clockwise, third)
}

def base(n, x, y)
  case [x>>(n-1), y>>(n-1)]
    when [0, 0]; Sub[:J0]
    when [1, 0]; Sub[:L0]
    when [1, 1]; Sub[:F0]
    when [0, 1]; Sub[:T0]
  end
end

def solve(n, x, y, *fields)
  if n == 1
    puts fields.join(" ").sub(/.0/, "  ")
  else
    n = n - 1
    nn = 2 ** n
    x, y = x % nn, y % nn
    subs = fields.collect { |f|
      # subsquares can be looked up, for :X0 we need proper tromino
      Trominos.include?(f) ? base(n, x, y) : Sub[f]
    }
    solve(n, x, y, *subs.collect { |s0, s1, s2, s3|  [s0, s1] }.flatten)
    solve(n, x, y, *subs.collect { |s0, s1, s2, s3|  [s3, s2] }.flatten)
  end
end

if ARGV[0].to_i == 0
  STDERR.puts "Usage:  #{$0} n    # where the field is 2**n square"
else
  n = ARGV[0].to_i
  size = 2 ** n
  x, y = rand(size), rand(size)
  puts "Hole at (#{x}, #{y})  # note that (0, 0) is top left"
  b = base(n, x, y)
  solve(n, x, y, *b.values_at(0, 1))
  solve(n, x, y, *b.values_at(3, 2))
end
