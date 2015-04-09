#!/usr/bin/env ruby -wKU

require "test/unit"
require "magic_square.rb"

class MagicSquareTest < Test::Unit::TestCase
  def test_magicness
    
    # here's a magic square of size 5
    m = Matrix[
      [15, 8, 1,24,17],
      [16,14, 7, 5,23],
      [22,20,13, 6, 4],
      [ 3,21,19,12,10],
      [ 9, 2,25,18,11]
    ]
    assert m.magic?

    # here's another
    m = Matrix[
      [19,21, 3,10,12],
      [25, 2, 9,11,18],
      [ 1, 8,15,17,24],
      [ 7,14,16,23, 5],
      [13,20,22, 4, 6]
    ]
    assert m.magic?
    
    # one of size 9
    m = Matrix[
      [45,34,23,12, 1,80,69,58,47],
      [46,44,33,22,11, 9,79,68,57],
      [56,54,43,32,21,10, 8,78,67],
      [66,55,53,42,31,20,18, 7,77],
      [76,65,63,52,41,30,19,17, 6],
      [ 5,75,64,62,51,40,29,27,16],
      [15, 4,74,72,61,50,39,28,26],
      [25,14, 3,73,71,60,49,38,36],
      [35,24,13, 2,81,70,59,48,37]
    ]
    assert m.magic?
    
  end
  
  def test_exceptions
    assert_raise ArgumentError do 
      m = Matrix.new_magic_square(2)
    end
    
    assert_raise ArgumentError do
      m = Matrix.new_magic_square(-1)
    end
  end
  
  def test_generator
    assert_equal Matrix.new_magic_square(1), Matrix[[1]]
    
    3.upto(100) do |n|
      s = Process.times
      m = Matrix.new_magic_square(n)
      t = Process.times
      # puts sprintf("size: %10d generated in utime: %8.2f\tstime: %8.2f", n, t.utime-s.utime, t.stime-s.stime)
      assert m.magic?
      u = Process.times
      # puts sprintf("size: %10d tested in utime: %8.2f\tstime: %8.2f", n, u.utime-t.utime, u.stime-t.stime)
    end
  end
end