#!/usr/bin/ruby

# Rubyquiz #57 -- Weird Numbers
# -----------------------------
# Levin Alexander <levin@grundeis.net>

module Enumerable
  def sum
    inject(0) {|s,elem| s+elem}
  end
end

class Array
  def subsets
    (0...2**length).collect {|i|
       values_at(*(0...length).find_all {|j| i&(1<<j)>0 })
    }
  end
end

class Integer
  def abundant?
    divisors.sum > self
  end

  def semiperfect?
    divisors.subsets.any? { |set| set.sum == self }
  end

  def weird?
    abundant? and not semiperfect?
  end

  def divisors
    (1...self).select { |i| self % i == 0 }
  end
end

if __FILE__ == $0
  0.upto(ARGV[0].to_i) { |i|
    if i.weird?
      puts i
    else
      warn "#{i} is not weird" if $DEBUG
    end
  }
end
