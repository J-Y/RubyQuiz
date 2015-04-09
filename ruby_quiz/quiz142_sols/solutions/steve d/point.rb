class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def <=>(point)
    Math::sqrt((point.y - @y)**2 + (point.x - @x)**2)
  end

  def eql?(point)
    point.x == @x and point.y == @y
  end

  alias :== :eql?
end

def P(x, y)
  Point.new(x, y)
end