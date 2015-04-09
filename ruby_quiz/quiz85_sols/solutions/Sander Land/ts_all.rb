class FWITest < Test::Unit::TestCase
 def test_unsigned_8
   uint8 = UnsignedFWI(8)
	n=uint8.new(0xFF)
	assert_equal(255 , n)
	n += 2
	assert_equal(1 , n)
	n = n << 1
	assert_equal(2 , n)
   n = n >> 1
	assert_equal(1 , n)
	assert_equal(254 , ~n)
   n += 12
	assert_equal(13 , n)
	n = n & 0x0E
	assert_equal(12 , n)
	n -= 13
	assert_equal(255 , n)
 end

 def test_signed_8
   int8 = SignedFWI(8)
	n = int8.new(1)
	assert_equal(n,1)
	n = n << 7
	assert_equal(-128 , n)
	n -= 1
	assert_equal(127 , n)
   n = n >> 6
	assert_equal(1 , n)
	n -= 2
	assert_equal(-1 , n)
	n = n ^ 0xF3
	assert_equal(12 , n)
	n = n | 0x01
	assert_equal(13 , n)
 end

 def test_too_wide
   uint8 = UnsignedFWI(8)
   assert_equal(238, uint8.new(0) + 0xFFEE)
 end

 def test_short_length_unsigned
   uint3 = UnsignedFWI(3)
	uint10 = UnsignedFWI(10)
	n = uint3.new(8)
	assert_equal(0, n)
	n -= 7
	assert_equal(1, n)
	assert_equal(0, n**23 + 7)
	m = uint3.new(8)
	assert_equal(1, n + m)
   assert_equal(1, m + n)
   assert_equal(1, 8 + n)
	l = uint10.new(11)
   assert_equal(1100-1024, l*100)
   assert_equal(1100-1024, 100*l)
 end

 def test_short_length_signed
   int3 = SignedFWI(3)
	n = int3.new(4)
	assert_equal(-4, n)
   assert_equal(3 , (+n)-1)
   assert_equal(n , 8+n)
   assert_equal(-n, n)
	n -= 1
	assert_equal(3 , n)
 end

 def test_long_length_signed
   int76 = SignedFWI(76)
	n = int76.new( 1<<75 )
	assert_equal(-(1<<75) , n)
	n -= 1
   assert_equal((1<<75)-1 , n)
	n = int76.new(2)
	n *= (1<<75)-1
	assert_equal(-2 , n)
 end

 def test_power
   uint3 = UnsignedFWI(3)
   assert_equal(2, 2 ** uint3.new(1))
	assert_equal(0, 2 ** uint3.new(3))
	assert_equal(0, 2 ** uint3.new(67))
	assert_equal(1, 3 ** uint3.new(2))
	assert_equal(3, uint3.new(3) ** uint3.new(-1)) # 3**7 mod 8
 end
end
