# test harness for ruby quiz 85
# see it at:
# http://www.rubyquiz.com/quiz85.html

require 'test/unit'
require 'UnsignedFixedWidthInt.rb'
require 'SignedFixedWidthInt.rb'


class TestUnsignedFixedWidthInt < Test::Unit::TestCase
 def test_quiz_example_unsigned
   n = UnsignedFixedWidthInt.new(0xFF, 8)
   assert_equal( n, 255 )
   n += 2
   assert_equal( n, 1 )
   n = n << 1
   assert_equal( n, 2 )
   n = n >> 1
   assert_equal( n, 1 )
   assert_equal( ~n, 254 )
   n += 12
   assert_equal( n, 13 )
   n = n & 0x0E
   assert_equal( n, 12 )
 end
 def test_quiz_example_too_wide
   n = UnsignedFixedWidthInt.new(0x0, 8)
   assert_equal( n, 0 )
   n += 0xFFEE
   assert_equal( n, 238 )
 end
end

class TestUnsignedFixedWidthInt < Test::Unit::TestCase
 def test_quiz_example_signed
   n = SignedFixedWidthInt.new(0x01, 8)
   assert_equal( n, 1 )
   n = n << 7
   assert_equal( n, -128 )
   n -= 1
   assert_equal( n, 127 )
   n = n >> 6
   assert_equal( n, 1 )
   n -= 2
   assert_equal( n, -1 )
   n = n ^ 0xF3
   assert_equal( n, 12 )
   n = n | 0x01
   assert_equal( n, 13 )
 end
end
