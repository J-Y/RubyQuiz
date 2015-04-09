module Enumerable
  # syntactic sugar
  def sum
    inject(0) { |sum, element| sum += element }
  end
end

module Weird
  # Returns proper divisors of `self`, i.e. all divisors except `self`.
  # Optimization: cached to improve speed - only small benefit for `weird_numbers_less_than`.
  def proper_divisors
    @proper_divisors ||= calculate_proper_divisors.freeze
  end
  
  # True if `self` is abundant, i.e. < the sum of its proper divisors
  def abundant?
    self < proper_divisors.sum
  end
  
  # True if `self` is semiperfect, i.e. at least one subset of `self`'s divisors forms a partition of `self`
  def semiperfect?
    !find_partition_from(proper_divisors.reverse).nil?
  end
  
  # True if self is a weird number, i.e. abundant and not semiperfect.
  # Optimization: tests `abundant?` first because it's a lot faster.
  def weird?
    abundant? and not semiperfect?
  end
  
  # Syntactic sugar for Kernel's `weird_numbers_less_than` method below
  def even?
    self % 2 == 0
  end

  protected
  # Finds one partition of `self` composed of integers taken without replacement from
  # `set`. Only finds one, because all we need to know is whether there are any.
  #
  # Assumptions: set is sorted in decreasing order
  # Protected because I want to call it from a unit test via `send`.
  def find_partition_from(set)
    return nil if set.empty? # recursion termination condition: no partition found

    # find index of largest number < self in set (which is assume sorted in decreasing order)
    start = nil
    set.each_with_index do |element, index|
      return [element] if element == self # recursion termination condition: partition found 
      if element < self # found largest number < self
        start = index
        break
      end
    end

    # recursively construct partition
    partition = nil
    unless start.nil?
      start.upto(set.length-1) do |index|
        break unless partition.nil?
        biggest, tailset = set[index], set[(index+1)..-1]
        partition = (self - biggest).find_partition_from(tailset)
        partition.insert(0, biggest) unless partition.nil?
      end
    end

    partition
  end

  private
  # Actually calculates (i.e. not cached) and returns all proper divisors of `self`.
  # Optimization: it turned out that inserting the divisors in sorted order was slower,
  #               at least the way I tried it. Uniq does not pose much of a burden either.
  def calculate_proper_divisors
    return [] if self == 1
    result = [1]
    2.upto(Math.sqrt(self).floor) do |candidate|
      # add both candidate and quotient, since they are both divisors
      result << candidate << (self / candidate) if self % candidate == 0
    end
    result.sort.uniq # uniq is needed for perfect squares
  end
end

class Fixnum; include Weird; end
class Bignum; include Weird; end # optimistic about CPU power!

# Optimization: `check_odd` parameter: there are no odd weird numbers < 10**19 [Weisstein, 2005], so 
# in general you should leave this flag at its default value of `false`. This provides a modest speedup
# (something like a factor of 1.5. I think the reason it's not more is there are few odd abundant numbers).
#
# [Weisstein, 2005] Eric W. Weisstein. "Weird Number." From MathWorld--A Wolfram Web Resource.
#                   http://mathworld.wolfram.com/WeirdNumber.html
def weird_numbers_less_than(n, check_odd = false)
  (1...n).find_all { |number| (check_odd or number.even?) and number.weird? }
end

if __FILE__ == $0
  p weird_numbers_less_than(ARGV[0].to_i, (ARGV[1] == 'check_odd'))
end
