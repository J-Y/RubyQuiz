# 
# Rubyquiz #65 (Splitting the Loot)
# Levin Alexander <levin@grundeis.net>
#

module Enumerable
  def sum; inject { |a,b| a+b } end

  def all_equal?
    inject { |a,b| break false unless a == b; b } != false
  end
end

class Object
  def if_false
    self ? self : yield
  end
end

class Symbol
  def to_proc; proc { |obj| obj.send(self) }; end
end

class Array
  def rest; self[1..-1]; end
end

class Distributor
  include Enumerable

  def initialize(persons, pieces)
    @pieces = pieces.sort.reverse # distribute big pieces first
    @persons = persons
  end

  def each(&blk)
    dist = Array.new(@persons) { [] }
    sums = Array.new(@persons) { 0 } # avoid recalculating the sums

    # special case
    return unless (@pieces.sum % @persons) == 0
    
    @expected = @pieces.sum / @persons
    
    distribute(0, sums, dist, @pieces, &blk)
  end
  
  private
  
  def distribute(depth, sums,dist,pieces,&blk)
    if pieces.empty? 
      yield dist if sums.all_equal?
    else
      first_piece, rest = pieces.first, pieces.rest
        
      (0...@persons).each { |p|
        # start with a different person at every turn so that we 
        # don't end up giving everything to the first guy
        # in the beginning
        # 
        p = (p+depth) % @persons

        dist[p].push first_piece
        sums[p] += first_piece

        # recursively distribute the rest
        # 
        distribute(depth+1, sums, dist, rest, &blk) unless sums[p] > @expected
  
        # undo everything.  This avoids having to duplicate the arrays
        # 
        dist[p].pop
        sums[p] -= first_piece
      }
    end
  end
end

if __FILE__ == $0
  
  persons = ARGV.shift.to_i
  loot = ARGV.map(&:to_i)

  Distributor.new(persons, loot).find { |dist|
      dist.each_with_index { |pieces,person|
      puts "#{person+1}: #{pieces.join(' ')}"
    }
  }.if_false {
    warn "It is not possible to fairly split this treasure #{persons} ways"
  }

end
