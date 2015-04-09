=begin
Justin Ethier
May 2007
Solution to: http://www.rubyquiz.com/quiz125.html

Test cases for the fractal model class.
=end

$:.unshift File.join(File.dirname(__FILE__), "..")
require 'test/unit'
require 'fractal_model.rb'

class TestFractalModel < Test::Unit::TestCase
  
  def setup
    @fract = FractalModel.new
  end

  def test_build_basecase
    list = @fract.build(0)
    assert_equal([0], list)
  end

  def test_build_01
    list = @fract.build(1)
    assert_equal([0, 90, 0, 270, 0], list)
  end

  def test_build_02
    list = @fract.build(2)
    
    assert_equal([
    0, 90, 0, 270, 0,
    90, 180, 90, 0, 90, # ULURU, 90 deg rotation
    0, 90, 0, 270, 0,
    270, 0, 270, 180, 270, # DRDLD, -90 deg rotation
    0, 90, 0, 270, 0], list)
  end
end
