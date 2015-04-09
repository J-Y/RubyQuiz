#!/usr/bin/env ruby
#
# Ruby Quiz Weird Numbers solution.
#
# I found only two significant optimizations:
# 1. Use continuations when generating the powerset of
#    divisors to sum. Evaluate each sum immediately
#    and break upon determining the number is semiperfect.
# 2. Sort the divisors in descending order so that
#    subsets involving the larger divisors are considered
#    first.
#
# On my machine, generating results for numbers up to 5000
# took less than a minute. Generating results up to 12000
# took almost twenty minutes.
#
# This powerset implementation was inspired by a post to
# Ruby-Talk by Robert Klemme on May 14, 2004:
# 
http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/100258?help-en
#
#

module Enumerable

  def powerset
    for element_map in 0...(1 << self.length) do
      subset = []
      each_with_index do |element, index|
        subset << element if element_map[index] == 1
      end
      yield subset
    end
  end

end

class Array

  def sum
    return self.inject { |total,x| total += x }
  end

end

class Integer

  def weird?
    divs = self.divisors.reverse
    return false unless divs.sum > self
    divs.powerset { |subset| return false if subset.sum == self }
    return true
  end

  def divisors
    list = []
    (1..Math.sqrt(self).to_i).each do |x|
      if (self / x) * x == self
        list << x
        list << (self / x) unless x == 1 or (self / x) == x
      end
    end
    return list.sort
  end

end

####################

(1..5000).each { |n| puts n if n.weird? }
