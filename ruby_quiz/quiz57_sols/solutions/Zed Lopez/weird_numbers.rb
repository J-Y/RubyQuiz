require 'set'

class Subsets
  def initialize(set, start)
    @set = set.to_a.uniq.sort
    @num_elements = start - 1
    @map = {}
    @set.each_with_index {|k, v| @map[k] = v+1}
  end

  # returns each subset, in turn. Returns nil when there are no more
  def succ
    if @combo == nil or @combo == @set[-@num_elements..-1]
      return nil if (@num_elements +=1) > @set.length
      @combo = @set[0,@num_elements]
    else
      index = (1..@num_elements).find {|i| @combo[-i] < @set[-i]}
      @combo[-index, index] = @set[@map[@combo[-index]], index]
    end
    @combo
  end

  def find
    while(x = succ)
      break if yield x
    end
    x
  end
end

class Integer

  def proper_divisors
    return [] if self < 2
    div = Set.new [1]
    2.upto(Math.sqrt(Float.induced_from(self)).to_i) {|i|
      quotient, modulus = self.divmod(i)
      div.merge([i,quotient]) if modulus.zero?
    }
    div.to_a.sort
  end

  def abundant?
    self > 11 and [0].concat(proper_divisors).inject {|sum,n| sum += n} > self
  end

  def semiperfect?
    return nil if self < 6
    subsets = Subsets.new(proper_divisors, 2)
    subsets.find {|subset| [0].concat(subset).inject {|sum,n| sum += n} == self }
  end

  def weird?
    self > 69 and abundant? and not semiperfect?
  end
end

n = gets.strip
exit if n =~ /\D/ or n !~ /[^0]/
p (1..n.to_i).find_all {|i| i.weird? }
