class Array

  # sum of array elements
  def sum
    self.inject { |sum, term| sum + term }
  end

  # sum of array elements less than +limit+
  def sum_below(limit) 
    self.inject(0) { |sum, term| sum + (term < limit ? term : 0) }
  end

end

class Integer

  # returns list of proper divisors (including 1 but excluding
  # the number itself)
  def divisors
    d1 = [1]
    d2 = []
    n = 2
    while n * n <= self
      if (a = self % n) == 0
        d1.push n
        if (b = self / n) != n
          d2.unshift b
        end
      end
      n = n + 1
    end
    d1 + d2
  end

  # true if number is abundant (i.e. sum of proper divisors
  # is greater than the number itself)
  def abundant?
    divisors.sum > self
  end

  # true if number is weird (abundant, but no subset of
  # proper divisors sums to the number)
  def weird?
    div = divisors
    sum = div.sum
    sum > self && !has_sum(div.reverse, sum, self)
  end

  private

  # given an array of Integers, and its current sum, and a target
  # return true if any combination of the array elements sums to
  # the target.
  def has_sum(arr, sum, target)
    delta = sum - target
    return false if delta < 0
    return true if arr.include? delta
    return false if arr.sum_below(delta) < delta
    arr.each_with_index do |n, i|
      next if n == 0 || n > delta
      arr[i] = 0
      return true if has_sum(arr, sum - n, target)
      arr[i] = n
    end
    false
  end

end

if $0 == __FILE__

  limit = ARGV.shift or begin
    puts "Usage: $0 limit"
    exit 1
  end
  $stdout.sync = true
  70.step(limit.to_i, 2) {|i| puts i if i.weird? }

end
