# $ ruby toothpick.rb 510
# 510:  (5x6x17) -> 32

# Will return the toothpick expression with the minimum
# number of toothpicks. In the case of tie-breaks, it will return
# the number with the fewest '+' signs.

# toothpick expressions are stored like:
# [[1], [3 ,4], [5, 6]] ~ 1 + 3*4 + 5*6

class Integer
  def divisors
    (2..(self-1)).select do |i|
      self.divmod(i)[1] == 0
    end
  end
end

class Toothpicks
  # contains the factorizations of integers with the minimum toothpick counts
  FACTORIZATIONS        = [nil, [1], [2], [3], [4], [5], [6], [7]]
  # contains the best toothpick expression for each integer
  SIMPLIFICATIONS       = [nil, [1], [2], [3], [4], [5], [6], [7]]
  # contains the best toothpick expression's toothpick count
  SIMPLIFICATION_COUNTS = [nil, 1, 2, 3, 4, 5, 6, 7]
  # contains the best toothpick expressions + count
  PLUS_COUNTS           = [nil, 0, 0, 0, 0, 0, 0, 0]

  def self.go(int, print=false)
    r = nil
    1.upto(int) do |i|
      r = simplify(i)
      puts "#{i}:  "+display(r) if print
    end
    r
  end

  # counts toothpicks in an array
  def self.count(array)
    array.flatten.inject{|sum, el| sum+el} + 2*array.flatten.length - 2
  end

  # just pretty prints the toothpick expression
  def self.display(array)
    str = "("
    array.each do |el|
      if el.is_a? Array
        str << el.join("x")
      elsif el.is_a? Integer
        str << el.to_s
      end
      str << " + "
    end
    str[0..(str.length-4)] << ") -> #{count(array)}"
  end

  # factorize an integer using the fewest toothpicks possible.
  # Recursive on multiplication.
  def self.factorize(int)
    if FACTORIZATIONS[int]
      result = FACTORIZATIONS[int]
    else
      best = [int]
      best_value = count(best)
      sqrt = Math::sqrt(int.to_f).to_i
      int.divisors.select{|d| d <= sqrt}.each do |div|
        current = [factorize(div), factorize(int/div)].flatten
        value = count(current)
        if value < best_value
          best = current
          best_value = value
        end
      end
      FACTORIZATIONS[int] = best
    end
  end

  # simplify an integer into a sum of factorized integers using
  # the fewest toothpicks possible.
  # (assumes that all simplifications less that int have already been done)
  # Recursive on bi-partition.
  def self.simplify(int)
    factorization = factorize(int)
    best = 0
    best_value = count(factorization)
    best_plus_count = 0
    # iterate over all possible bi-partitions of int, and save the best
    1.upto(int/2) do |i|
      value = SIMPLIFICATION_COUNTS[i] + SIMPLIFICATION_COUNTS[-i] + 2
      if value < best_value
        best = i
        best_value = value
        best_plus_count = PLUS_COUNTS[i] + PLUS_COUNTS[-i] + 1
      elsif value == best_value
        plus_count = PLUS_COUNTS[i] + PLUS_COUNTS[-i] + 1
        if plus_count < best_plus_count
          best = i
          best_value = value
          best_plus_count = plus_count
        end
      end
    end
    SIMPLIFICATION_COUNTS[int] = best_value
    PLUS_COUNTS[int] = best_plus_count
    if best == 0
      SIMPLIFICATIONS[int] = [factorization]
    else
      SIMPLIFICATIONS[int] = SIMPLIFICATIONS[best] + SIMPLIFICATIONS[-best]
    end
  end
end


if ARGV[0] == "test"
  require 'test/unit'
  class TestToothpick < Test::Unit::TestCase
    def test_factorize
      assert_equal [3, 4], Toothpicks.factorize(12)
      assert_equal [13],   Toothpicks.factorize(13)
      assert_equal [2, 7], Toothpicks.factorize(14)
    end

    def test_count
      assert_equal 12, Toothpicks.count( [[3,4], [1]] )
      assert_equal 11, Toothpicks.count( [[3,6]] )
      assert_equal 14, Toothpicks.count( [[1], [3,6]] )
    end

    def test_simplify_through_go
      assert_equal [[1]], Toothpicks.go(1)
      assert_equal [[3]], Toothpicks.go(3)
      assert_equal [[3, 3]], Toothpicks.go(9)
      assert_equal [[1], [3, 6]], Toothpicks.go(19)
    end
  end
else
  r = Toothpicks.go(ARGV[0].to_i)
  puts "#{ARGV[0].to_i}:  "+Toothpicks.display(r)
end
