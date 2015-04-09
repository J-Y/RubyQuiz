require 'test/unit'
require 'point'

class PointTest < Test::Unit::TestCase
  def test_distance
    assert_equal 0, P(1.0, 1.0) <=> P(1.0, 1.0)
    assert_equal 1, P(1.0, 1.0) <=> P(2.0, 1.0)
    assert_equal 4, P(4.0, 0.0) <=> P(0.0, 0.0)
    assert_equal Math::sqrt(200), P(10, 0) <=> P(0, 10)
  end
end