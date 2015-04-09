require 'c_int'
require 'test/unit'

class CIntTest < Test::Unit::TestCase
  def test_no_bits
    assert_raises(ArgumentError) { UnsignedFixedWidthInt.new(0, 0) }
    assert_raises(ArgumentError) { UnsignedFixedWidthInt.new(0, -1) }
  end

  def test_one_bit
    n = UnsignedFixedWidthInt.new(0xFF, 1)
    assert_equal 1, n

    n += 1
    assert_equal 0, n

    n = SignedFixedWidthInt.new(0xFF, 1)
    assert_equal(-1, n)

    n += 1
    assert_equal 0, n

    n += 1
    assert_equal(-1, n)
  end

  def test_unsigned
    n = UnsignedFixedWidthInt.new(0xFF, 8)
    assert_equal 255, n

    n += 2
    assert_equal 1, n

    n = n << 1
    assert_equal 2, n

    n = n >> 1
    assert_equal 1, n

    assert_equal 254, (~n)

    n += 12
    assert_equal 13, n

    n = n & 0x0E
    assert_equal 12, n

    n = n * 24
    assert_equal 32, n

    n = n / 15
    assert_equal 2, n
  end

  def test_signed
    n = SignedFixedWidthInt.new(0x01, 8)
    assert_equal  1, n

    n = n << 7
    assert_equal(-128, n)

    n -= 1
    assert_equal 127, n

    n = n >> 6
    assert_equal 1, n

    n -= 2
    assert_equal(-1, n)

    n = n ^ 0xF3
    assert_equal  12, n

    n = n | 0x01
    assert_equal  13, n

    n = +n
    assert_equal 13, n

    n = -n
    assert_equal(-13, n)
  end

  def test_too_wide
    n = UnsignedFixedWidthInt.new(0x0, 8)
    n += 0xFFEE
    assert_equal 238, n
  end

  def test_signed_shift_right
    n = SignedFixedWidthInt.new(0x80, 8)
    n = n >> 1
    assert_equal(-64, n) # with sign extension
  end

  def test_equal
    s1 = SignedFixedWidthInt.new(-1, 4)
    s2 = SignedFixedWidthInt.new(-1, 4)
    s3 = SignedFixedWidthInt.new(1, 4)
    u1 = UnsignedFixedWidthInt.new(1, 4)
    u2 = UnsignedFixedWidthInt.new(1, 4)
    assert u1 != s1
    assert s1 != s3
    assert u1 == u2
    assert s1 == s2
    assert s3 == u1
    assert(-1 == s1)
    assert s1 == -1
  end

  def test_conversions
    n = SignedFixedWidthInt.new(-100, 7)
    assert "-100", n.to_s
    assert "-100", n.inspect
    assert(-100, n.to_i)
    assert(-100, n.to_int)
  end

  def test_coerce
    n = UnsignedFixedWidthInt.new(1, 4)
    assert 1.1 > n
    assert 0.9 < n
    assert 1 == n
  end

  def test_comparison
    s = SignedFixedWidthInt.new(-1, 4)
    u = UnsignedFixedWidthInt.new(1, 4)
    assert u > s
    assert s < u
    assert s < 0
    assert u > 0
    assert 0 > s
    assert 0 < u
    assert_equal(-1, s <=> u)
    assert_equal 1, u <=> s
    assert_equal 0, 1 <=> u
    assert_equal 0, -1 <=> s
  end
end
