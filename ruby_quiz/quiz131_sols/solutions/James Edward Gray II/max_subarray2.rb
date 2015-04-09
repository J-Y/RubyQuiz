#!/usr/bin/env ruby -wKU

class Array
  def max_subarray
    sum,      start,      length      = self[0], 0,     1
    best_sum, best_start, best_length = sum,     start, length
    
    each_with_index do |n, i|
      sum, start, length = 0, i, 0 if sum < 0
      
      sum    += n
      length += 1
      
      best_sum, best_start, best_length = sum, start, length if sum > best_sum
    end
    
    self[best_start, best_length]
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    require "test/unit"

    class TestMaxSubarray < Test::Unit::TestCase
      def test_single_element
        -1.upto(1) { |n| assert_equal(Array(n), Array(n).max_subarray) }
      end
      
      def test_all_positive
        assert_equal([1, 2, 3], [1, 2, 3].max_subarray)
      end
      
      def test_all_negative
        assert_equal([-1], [-3, -2, -1].max_subarray)
      end
      
      def test_quiz_example
        assert_equal([2, 5, -1, 3], [-1, 2, 5, -1, 3, -2, 1].max_subarray)
      end
    end
  else
    p ARGV.map { |n| Integer(n) }.max_subarray
  end
end
