#!ruby
=begin

The Quiz was real fun and I spent quite a lot of time on it.  Below
source is rather easy, but believe me I tried lots of different ways
(such as dynamic binary knapsacks etc.), most of them suck because they
need to many method calls.

The code takes about 30 seconds to find all Weird Numbers up to 10_000:

             70, 836, 4030, 5830, 7192, 7912, 9272.

The code doesn't scale rather well, the caches would need to be
optimized for that.

=end

class Integer
  # 70, 836, 4030, 5830, 7192, 7912, 9272, 10430
  def weird?
    !has_semiperfect? && !weird2?
  end

  SEMIPERFECT = {nil => 'shortcut'}

  def weird2?(divisors=proper_divisors)
    return true  if divisors.any? { |x| SEMIPERFECT[x] }
    if brute(self, divisors)
      SEMIPERFECT[self] = true
    else
      false
    end
  end

  SMALL_SEMIPERFECT = [6, 20, 28]    # + [88, 104, 272]

  def has_semiperfect?
    SMALL_SEMIPERFECT.any? { |v| self % v == 0 }
  end

  def proper_divisors
    d = []
    sum = 0
    2.upto(Math.sqrt(self)) { |i|
      if self % i == 0
        d << i << (self / i)
        sum += i + (self / i)
      end
    }

    return [nil]  unless sum > self
    d << 1
  end

  def brute(max, values)
    values.sort!

    values.delete max / 2
    max = max / 2

    s = values.size
    (2**s).downto(0) { |n|
      sum = 0
      s.times { |i| sum += values[i] * n[i] }
      return true  if sum == max
    }
    false
  end
end

if ARGV[0]
  n = Integer(ARGV[0])
else
  n = 10_000
end

2.step(n, 2) { |i|
  p i  if i.weird?
}
