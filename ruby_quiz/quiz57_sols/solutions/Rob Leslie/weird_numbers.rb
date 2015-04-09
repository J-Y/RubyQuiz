#! /usr/bin/ruby
#
# Ruby program to find all the weird numbers less than a given input
# Rob Leslie <rob@mars.org>
#

class Integer
  WEIRD_ODD_UNKNOWN_THRESHOLD = 10 ** 18

  def weird?
    # Odd numbers less than 10**18 are not weird. (Bob Hearn, July 2005)
    return false if self & 1 == 1 && self < WEIRD_ODD_UNKNOWN_THRESHOLD

    # Weird numbers are abundant. To be abundant, the sum of the divisors
    # must be greater than twice this number. Equivalently, the sum of
    # the proper divisors (excluding the number itself) must be greater
    # than this number.
    divisors = self.divisors
    sum = divisors.inject { |sum, x| sum + x } - self
    return false unless sum > self

    # Weird numbers are not semiperfect. To be semiperfect, the sum of a
    # subset of the divisors must be equal to this number. Equivalently,
    # the sum of another subset (the complement set) of divisors must be
    # equal to the difference between this number and the sum of all its
    # divisors.
    excess = sum - self
    addends = divisors.reject { |x| x > excess }
    sum = addends.inject { |sum, x| sum + x }

    # Trivially semiperfect or non-semiperfect?
    return false if sum == excess || addends.include?(excess)
    return true if sum < excess

    # Default non-semiperfect test (with special case speed optimization)
    self < 222_952 ? 9_272 == self : !excess.sum_of_subset?(addends)
  end

  def divisors
    list = (2..Math.sqrt(self).floor).select { |i| (self % i).zero? }
    list += list.collect { |i| self / i }
    [1, *list].uniq
  end

  def sum_of_subset?(addends)
    first = addends.first
    return true if self == first
    return false unless addends.length > 1
    rest = addends[1..-1]
    (self - first).sum_of_subset?(rest) or self.sum_of_subset?(rest)
  end
end

input = ARGV.shift.to_i

70.upto(input - 1) do |number|
  puts number if number.weird?
end
