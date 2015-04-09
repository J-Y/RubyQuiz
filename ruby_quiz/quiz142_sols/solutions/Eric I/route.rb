# A component to a solution to RubyQuiz #142 (rubyquiz.com)
# LearnRuby.com
# Released under the Creative Commons Attribution Non-commercial Share
# Alike license (see:
# http://creativecommons.org/licenses/by-nc-sa/3.0/).


require 'enumerator'
require 'grid'


# The Route class represents a single route through the grid,
# represented by an array of points, where each point is an array
# containing the x and y coordinates.
class Route
  include Enumerable
  attr_reader :length, :points, :size, :previous, :operation

  # Creates a new route.  If a Grid is passed in, the route generated
  # is completely random.  If another Route is passed in, the route
  # generated is a mutation (recombination) of it.
  def initialize(from)
    case from
    when Grid
      @points = from.pts.sort_by { rand }
      @length = calculate_length
      @size = from.n
      @previous = nil
    when Route
      @points = from.points  # share points for now
      @length = from.length
      @size = from.size
      @previous = from
    else
      raise ArgumentError.new("parameter must be either a Grid or Route")
    end
  end

  # each is needed to allow a Route to be Enumerable; sequences through
  # the ancestor routes produced recursively
  def each(seen = Hash.new, &proc)
    return if seen[self]
    seen[self] = true
    case @previous
    when Array
      @previous.each do |r| r.each(seen, &proc) end
    when Route
      @previous.each(seen, &proc)
    end
    yield self
  end

  # performs an exchange mutation as specified in the quiz description
  def exchange
    offspring = Route.new self
    offspring.operation = "exchange"
    
    # pick three indices at least two apart
    begin
      indices = Array.new(3) { rand(points.size + 1) }.sort
    end until (indices[0] - indices[1]).abs >= 1 &&
      (indices[1] - indices[2]).abs >= 1

    # return the points such that those b/w the pairs of indices are
    # exchanged
    offspring.points =
      @points[0...indices[0]] +
      @points[indices[1]...indices[2]] +
      @points[indices[0]...indices[1]] +
      @points[indices[2]...points.size]

    offspring
  end

  # performs a reverse mutation as specified in the quiz description
  def reverse
    offspring = Route.new self
    offspring.operation = "reverse"

    # pick two indices at least two apart
    begin
      indices = Array.new(2) { rand(points.size + 1) }
    end until (indices[0] - indices[1]).abs >= 2
    indices.sort!

    # return the points such that those b/w the indices are reversed
    offspring.points =
      @points[0...indices[0]] +
      @points[indices[0]...indices[1]].reverse +
      @points[indices[1]...points.size]

    offspring
  end

  # chooses a segment from self and reorders the points in that
  # segment based on the order they appear in other; the idea for this
  # came from James Koppel's solution
  def partner_guided_reorder(partner)
    offspring = Route.new self
    offspring.previous = [self, partner]
    offspring.operation = "partner guided reorder"

    # pick two indices at least two apart
    begin
      indices = Array.new(2) { rand(points.size + 1) }
    end until (indices[0] - indices[1]).abs >= 2
    indices.sort!

    # return the points such that those b/w the indices are reversed
    offspring.points =
      @points[0...indices[0]] +
      @points[indices[0]...indices[1]].sort_by { |p|
        partner.points.index(p) } +
      @points[indices[1]...points.size]

    offspring
  end

  protected

  attr_writer :operation, :previous

  def points=(new_points)
    @points = new_points
    @length = calculate_length
  end

  # returns the length of the route
  def calculate_length
    l = @points.enum_cons(2).inject(0) { |s, points|
      s + distance_between(*points)
    }

    # include distance to go from last point to first to make loop
    l + distance_between(@points[-1], @points[0])
  end

  # returns the distance b/w two points using the Pythagorean theorem
  def distance_between(p1, p2)
    Math.sqrt((p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2)
  end
end
