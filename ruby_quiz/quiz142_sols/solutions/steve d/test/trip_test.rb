require 'test/unit'
require 'trip'
require 'point'

class TripTest < Test::Unit::TestCase
  def test_distance
    trip = Trip.new([P(0,0), P(0,1), P(1,1), P(1,4)])
    assert_equal 5, trip.distance

    trip = Trip.new([P(0,0), P(10,10), P(0,0), P(20,20)])
    assert_equal 2 * Math::sqrt(200) + Math::sqrt(800), trip.distance
  end

  def test_diagnols
    no_diagnols = Trip.new([P(0,0), P(0,1), P(3,1)])
    assert_equal 0, no_diagnols.diagnols

    four_diagnols = Trip.new([P(0,0), P(1,1), P(0,2), P(3,3), P(0,4), P(100,4)])
    assert_equal 4, four_diagnols.diagnols
  end
end