require 'test/unit'
require 'travel_agency'

class TravelAgencyTest < Test::Unit::TestCase
  @@grid = Grid.new 7
  @@travel_agency = TravelAgency.new @@grid

  @@trip_evolutions = []
  track_evolution = proc do |trip|
    @@trip_evolutions << trip
  end

  @@trip = @@travel_agency.shortest_trip(:generations => 100, :callback_proc => track_evolution)

  def test_trip__covers_all_points
    assert_equal @@trip.points.first, @@trip.points.last, "trip doesn't end where it started"
    assert_equal @@grid.points.size + 1, @@trip.points.size
    assert_equal @@grid.points.size, (@@trip.points & @@grid.points).size
  end

  def test_trip__distance
    assert ! (@@trip.distance < @@grid.min), "You have a shorter distance than the minimum.  Impossible!"
    assert_in_delta @@grid.min, @@trip.distance, @@grid.min * 0.05
  end

  def test_trip__draw_svg
    puts "min: #{@@grid.min}"
    puts "actual: #{@@trip.distance}"
    File.open("trip.svg","w") {|f| f.write @@travel_agency.draw_svg(@@trip_evolutions) }
  end
end