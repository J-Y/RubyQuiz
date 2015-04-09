#!/usr/bin/env ruby

def make_change(amount, coins = [25, 10, 5, 1])
 coins = coins.sort.reverse

#  p amount
#  p coins

 best_change = Array.new(amount + 1)
 0.upto(amount) do |n|
   best_change[n] = coins.map do |c|
     n - c < 0 \
     ? [] \
     : (best_change[n - c].empty? && n != c \
        ? [] \
        : [c] + best_change[n - c])
   end.delete_if{ |a| a.empty? } \
   .sort{ |a, b| a.size <=> b.size }[0] || []
 end

#  p best_change

 best_change[amount]
end

if __FILE__ == $0

 require 'test/unit'

 class TestMakeChange < Test::Unit::TestCase
   def setup
     @_1071_coins = [10, 7, 1]
     @ua_coins = [50, 25, 10, 5, 2, 1]
     @au_coins = [200, 100, 50, 20, 10, 5]
   end

   def test_zero
     assert_equal([], make_change(0))
   end

   def test_change_equal_to_one_coin
     assert_equal([10], make_change(10, @_1071_coins))
     assert_equal([7], make_change(7, @_1071_coins))
   end

   def test_two_middles
     assert_equal([7, 7], make_change(14, @_1071_coins))
   end

   def test_us
     assert_equal([25, 10, 1, 1, 1, 1], make_change(39))
     assert_equal([25, 25, 25, 25], make_change(100))
     assert_equal([25, 25, 25, 10, 10, 1, 1, 1, 1], make_change(99))
   end

   def test_ua
     assert_equal([2, 2], make_change(4, @ua_coins))
     assert_equal([25, 10, 2], make_change(37, @ua_coins))
     assert_equal([50, 25, 10, 10, 2, 2], make_change(99, @ua_coins))
   end

   def test_24_1082
     assert_equal([8, 8, 8], make_change(24, [10,8,2]))
   end

   def test_au
     assert_equal([], make_change(1, @au_coins))
     assert_equal([20, 10, 5], make_change(35, @au_coins))
   end

   def test_15_1053
     assert_equal([5, 3, 3, 3], make_change(14, [10, 5, 3]))
   end

   def test_x97
     assert_equal([99, 99, 99], make_change(297, [100, 99, 1]))
     assert_equal([100, 99, 99, 99], make_change(397, [100, 99, 1]))
     assert_equal([100, 100, 99, 99, 99], make_change(497, [100, 99, 1]))
   end

   def test_4563
     assert_equal([97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97,
                   97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97,
                   97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97,
                   97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 89, 7, 5],
                  make_change(4563, [97, 89, 83, 79, 73, 71, 67, 61,
                                     59, 53, 47, 43, 41, 37, 31, 29,
                                     23, 19, 17, 13, 11, 7, 5, 3]))
   end

   def test_huge
#      assert_equal([], make_change(1_000_001))
   end
 end

end
