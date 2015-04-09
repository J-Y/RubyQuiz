class Turtle
  include Math # turtles understand math methods
  DEG = Math::PI / 180.0

  NORTH = 0.0
  HOME = [0, 0]

  alias run instance_eval

  def initialize
    self.clear
    self.pen_up
  end

  attr_reader :track, :xy, :heading

  # Place the turtle at [x, y]. The turtle does not draw when it changes
  # position.
  def xy=(coords)
    @xy = validate_coords(coords)
  end

  # Set the turtle's heading to <degrees>. Heading is measured CLOCKWISE from NORTH!
  def heading=(degrees)
    @heading = validate_degrees(degrees)
  end

  # Raise the turtle's pen. If the pen is up, the turtle will not draw;
  # i.e., it will cease to lay a track until a pen_down command is given.
  def pen_up
    @pen_up = true
  end

  # Lower the turtle's pen. If the pen is down, the turtle will draw;
  # i.e., it will lay a track until a pen_up command is given.
  def pen_down
    @pen_up = false
  end

  # Is the pen up?
  def pen_up?
    @pen_up
  end

  # Is the pen down?
  def pen_down?
    not self.pen_up?
  end

  # Places the turtle at the origin, facing north, with its pen up.
  # The turtle does not draw when it goes home.
  def home
    @xy = HOME
    self.heading = NORTH
  end

  # Homes the turtle and empties out its track.
  def clear
    @track = []
    home
  end

  # Turn right through the angle <degrees>.
  def right(degrees)
    h = self.heading + validate_degrees(degrees)
    self.heading = normalize_degrees(h)
  end

  # Turn left through the angle <degrees>.
  def left(degrees)
    h = self.heading - validate_degrees(degrees)
    self.heading = normalize_degrees(h)
  end

  # Move forward by <steps> turtle steps.
  def forward(steps)
    validate_steps(steps)
    normal_radians = to_rad(flip_turtle_and_normal(@heading))
    new_pt = [@xy[0] + steps * cos(normal_radians),
              @xy[1] + steps * sin(normal_radians)]

    add_segment_to_track @xy, new_pt if self.pen_down?
    @xy = new_pt
  end

  # Move backward by <steps> turtle steps.
  def back(steps)
    validate_steps(steps)

    normal_radians = to_rad(flip_turtle_and_normal(@heading))
    new_pt = [@xy[0] - steps * cos(normal_radians),
              @xy[1] - steps * sin(normal_radians)]

    if self.pen_down?
      add_segment_to_track @xy, new_pt
    end

    @xy = new_pt
  end

  # Move to the given point.
  def go(pt)
    validate_coords(pt)
    add_segment_to_track(self.xy, pt) if self.pen_down?
    self.xy = pt
  end

  # Turn to face the given point.
  def toward(pt)
    validate_coords(pt)
    delta_x = (pt[0] - self.xy[0]).to_f
    delta_y = (pt[1] - self.xy[1]).to_f
    return if delta_x.zero? and delta_y.zero?

    # Handle special cases
    case
    when delta_x.zero? # North or South
      self.heading = delta_y < 0.0 ? 180.0 : 0.0
    when delta_y.zero? # East or West
      self.heading = delta_x < 0.0 ? 270.0 : 90.0
    else
      # Calcs are done in non-turtle space so we have to flip afterwards
      quadrant_adjustment = if delta_x < 0.0 then 180 elsif delta_y < 0.0 then 360.0 else 0.0 end
      self.heading = flip_turtle_and_normal(to_deg(atan(delta_y / delta_x)) + quadrant_adjustment)
    end
  end

  # Return the distance between the turtle and the given point.
  def distance(pt)
    # Classic Pythagoras
    sqrt((pt[0] - @xy[0]) ** 2 + (pt[1] - @xy[1]) ** 2)
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

  private

  # Validations

  def validate_coords(coords)
    unless coords.respond_to? :[] and
           coords.respond_to? :length and
           coords.length == 2 and
           coords[0].kind_of? Numeric and
           coords[1].kind_of? Numeric
      raise(ArgumentError, "Invalid coords #{coords.inspect}, should be [num, num]")
    end
    coords
  end

  def validate_degrees(degrees)
    raise(ArgumentError, "Degrees must be numeric") unless degrees.kind_of? Numeric
    normalize_degrees(degrees)
  end

  def validate_steps(steps)
    raise(ArgumentError, "Steps must be numeric") unless steps.kind_of? Numeric
  end

  # Normalizations

  # Flip between turtle space degrees and "normal" degrees (symmetrical)
  def flip_turtle_and_normal(degrees)
    (450.0 - degrees) % 360.0
  end

  # Normalize degrees to interval [0, 360)
  def normalize_degrees(degrees)
    degrees += 360.0 while degrees < 0.0
    degrees % 360.0
  end

  def add_segment_to_track(start, finish)
    @track << [ start, finish ]
  end

  def to_rad(deg)
    deg * DEG
  end

  def to_deg(rad)
    rad / DEG
  end
end
