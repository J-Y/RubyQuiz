#!/usr/bin/env ruby
#
# Ruby Quiz Weird Numbers solution.
# Uses recursive sum_in_subset? approach borrowed from
# other solutions.
#

class Integer

  def weird?
    divisors = self.divisor_list
    abundancy = divisors.inject { |total,x| total += x } - self
    return false unless abundancy > 0
    smalldivisors = divisors.reverse.select { |j| j <= abundancy }
    return false if sum_in_subset?(smalldivisors, abundancy)
    return true
  end

  def sum_in_subset?(list, target)
    return false if target < 0
    return true if list.include?(target)
    return false if list.length == 1
    first = list.first
    rest = list[1..-1]
    sum_in_subset?(rest, target-first) or sum_in_subset?(rest, target)
  end

  def divisor_list
    list = []
    (1..Math.sqrt(self).to_i).each do |x|
      if self % x == 0
        list << x
        list << (self / x) unless x == 1 or (self / x) == x
      end
    end
    return list.sort
  end

end

####################

unless ARGV.length == 1
  puts "Usage: #{$0} <max_value>"
end
max_value = ARGV.shift.to_i
(1..max_value).each { |n| puts n if n.weird? }
