require 'point'

class Trip
  attr_reader :points, :grid

  def initialize(points)
    @points = points

    raise "Invalid point passed"  if @points.detect { |pt| ! pt.is_a? Point }
  end

  def distance
    last_point = @points.first
    distance = 0.0

    @points[1..-1].each do |point|
      distance += (point <=> last_point)
      last_point = point      
    end

    distance
  end

  def diagnols
    diags = 0

    last_point = points.first
    points.inject do |last_point, point|
      diags += 1 if point.x != last_point.x and point.y != last_point.y
      point
    end

    diags
  end
end