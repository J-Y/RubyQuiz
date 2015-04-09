#!/usr/bin/ruby

# Fixed Width Integer Class Unit Tests (Ruby Quiz #85)
# (C) 2006 Jürgen Strobel <juergen@strobel.info>
#
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any
# later version.

require "fixed_width_int.rb"
require 'test/unit'

class FWITest < Test::Unit::TestCase
  def test_unsigned
    assert_equal 255, (n = UnsignedFixedWidthInt.new(0xff, 8))
    assert_equal 1, (n += 2)
    assert_equal 2, (n = n << 1)
    assert_equal 1, (n = n >> 1)
    assert_equal 254, (~n)
    assert_equal 13, (n += 12)
    assert_equal 12, (n = n & 0x0E)

    assert_kind_of FixedWidthInt, n
    assert_instance_of UnsignedFixedWidthInt, n
    assert_equal 144, (n * n)
    assert_equal 0, (n-n)
    assert_equal 3, (m = -9 + n)
    assert_kind_of Integer, m
    assert_kind_of Float, n.to_f
  end

  def test_signed
    assert_equal 1, (n = SignedFixedWidthInt.new(0x01, 8))
    assert_equal -128, (n = n << 7)
    assert_equal 127, (n -= 1)
    assert_equal 1, (n = n >> 6)
    assert_equal -1, (n -= 2)
    assert_equal 12, (n = n ^ 0xF3)
    assert_equal 13, (n = n | 0x01)

    assert_kind_of FixedWidthInt, n
    assert_instance_of SignedFixedWidthInt, n
    assert_equal -169&0xff, (n * (-n))
    assert_equal 0, (n-n)
    assert_equal -1, (m = -14 + n)
    assert_kind_of Integer, m
    assert_kind_of Float, n.quo(17)
  end

  def test_too_wide
    assert_equal 0, (n = UnsignedFixedWidthInt.new(0x0, 8))
    assert_equal 238, (n += 0xFFEE)
  end
end
