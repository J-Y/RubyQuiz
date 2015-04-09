require "matrix"

class Turtle
  include Math # turtles understand math methods
  DEG = Math::PI / 180.0
  ORIGIN = [0.0, 0.0]
  NORTH = 0.0

  attr_accessor :track
  alias run instance_eval

  def initialize
     clear
  end

  attr_reader :xy, :heading

  # Place the turtle at [x, y]. The turtle does not draw when it changes
  # position.
  def xy=(pt)
     validate_point(pt)
     if pen_up?
        @xy = pt
     else
        pen_up
        @xy = pt
        pen_down
     end
     @xy
  end

  # Set the turtle's heading to <degrees>.
  def heading=(degrees)
     validate_angle(degrees)
     @heading = degrees % 360
  end

  # Raise the turtle's pen. If the pen is up, the turtle will not draw;
  # i.e., it will cease to lay a track until a pen_down command is given.
  def pen_up
     @segment = nil
  end

  # Lower the turtle's pen. If the pen is down, the turtle will draw;
  # i.e., it will lay a track until a pen_up command is given.
  def pen_down
     if pen_up?
        @segment = [@xy.dup]
        @track << @segment
     end
  end

  # Is the pen up?
  def pen_up?
     not @segment
  end

  # Is the pen down?
  def pen_down?
     not pen_up?
  end

  # Places the turtle at the origin, facing north, with its pen up.
  # The turtle does not draw when it goes home.
  def home
     pen_up
     @xy, @heading = ORIGIN, NORTH
  end

  # Homes the turtle and empties out it's track.
  def clear
     home
     @track = []
  end

  # Turn right through the angle <degrees>.
  def right(degrees)
     validate_angle(degrees)
     self.heading += degrees
  end

  # Turn left through the angle <degrees>.
  def left(degrees)
     validate_angle(degrees)
     self.heading -= degrees
  end

  # Move forward by <steps> turtle steps.
  def forward(steps)
     validate_dist(steps)
     go offset(steps)
  end

  # Move backward by <steps> turtle steps.
  def back(steps)
     validate_dist(steps)
     go offset(-steps)
  end

  # Move to the given point.
  def go(pt)
     validate_point(pt)
     @xy = pt
     @segment << @xy if pen_down?
  end

  # Turn to face the given point.
  def toward(pt)
     validate_point(pt)
     d = delta(pt)
     self.heading = atan2(d[0], d[1]) / DEG
  end

  # Return the distance between the turtle and the given point.
  def distance(pt)
     validate_point(pt)
     delta(pt).r
  end

  # Traditional abbreviations for turtle commands.
  alias fd forward
  alias bk back
  alias rt right
  alias lt left
  alias pu pen_up
  alias pd pen_down
  alias pu? pen_up?
  alias pd? pen_down?
  alias set_h heading=
  alias set_xy xy=
  alias face toward
  alias dist distance

  # Given a heading, build a unit vector in that direction.
  def facing
     rd = @heading * DEG
     Vector[ sin(rd), cos(rd) ]
  end

  # Offset the current position in the direction of the current
  # heading by the specified distance.
  def offset(dist)
     (Vector[*@xy] + (facing * dist)).to_a
  end

  # Build a delta vector to the specified point.
  def delta(pt)
     (Vector[*pt] - Vector[*@xy])
  end

  def validate_point(pt)
     raise ArgumentError unless pt.is_a?(Array)
     raise ArgumentError unless pt.size == 2
     pt.each { |x| validate_dist(x) }
  end

  def validate_angle(deg)
     raise ArgumentError unless deg.is_a?(Numeric)
  end

  def validate_dist(dist)
     raise ArgumentError unless dist.is_a?(Numeric)
  end

  private :facing
  private :offset
  private :delta
  private :validate_point
  private :validate_angle
  private :validate_dist
end
