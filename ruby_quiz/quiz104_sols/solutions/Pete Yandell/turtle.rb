class Turtle
   include Math # turtles understand math methods
   DEG = Math::PI / 180.0

   attr_accessor :track
   alias run instance_eval

   def initialize
     clear
   end

   attr_reader :xy, :heading

   # Place the turtle at [x, y]. The turtle does not draw when it changes
   # position.
   def xy=(coords)
     raise ArgumentError unless is_point?(coords)
     @xy = coords
   end

   # Set the turtle's heading to <degrees>.
   def heading=(degrees)
     raise ArgumentError unless degrees.is_a?(Numeric)
     @heading = degrees % 360
   end

   # Raise the turtle's pen. If the pen is up, the turtle will not draw;
   # i.e., it will cease to lay a track until a pen_down command is given.
   def pen_up
     @pen_is_down = false
   end

   # Lower the turtle's pen. If the pen is down, the turtle will draw;
   # i.e., it will lay a track until a pen_up command is given.
   def pen_down
     @pen_is_down = true
     @track << [@xy]
   end

   # Is the pen up?
   def pen_up?
     !@pen_is_down
   end

   # Is the pen down?
   def pen_down?
     @pen_is_down
   end

   # Places the turtle at the origin, facing north, with its pen up.
   # The turtle does not draw when it goes home.
   def home
     @heading = 0.0
     @xy = [0.0, 0.0]
     @pen_is_down = false
   end

   # Homes the turtle and empties out it's track.
   def clear
     @track = []
     home
   end

   # Turn right through the angle <degrees>.
   def right(degrees)
     raise ArgumentError unless degrees.is_a?(Numeric)
     @heading += degrees
     @heading %= 360
   end

   # Turn left through the angle <degrees>.
   def left(degrees)
     right(-degrees)
   end

   # Move forward by <steps> turtle steps.
   def forward(steps)
     raise ArgumentError unless steps.is_a?(Numeric)
     @xy = [@xy.first + sin(@heading * DEG) * steps, @xy.last + cos(@heading * DEG) * steps]
     @track.last << @xy if @pen_is_down
   end

   # Move backward by <steps> turtle steps.
   def back(steps)
     forward(-steps)
   end

   # Move to the given point.
   def go(pt)
     raise ArgumentError unless is_point?(pt)
     @xy = pt
     @track.last << @xy if @pen_is_down
   end

   # Turn to face the given point.
   def toward(pt)
     raise ArgumentError unless is_point?(pt)
     @heading = (atan2(pt.first - @xy.first, pt.last  - @xy.last) / DEG) % 360
   end

   # Return the distance between the turtle and the given point.
   def distance(pt)
     raise ArgumentError unless is_point?(pt)
     return sqrt((pt.first - @xy.first) ** 2 + (pt.last  - @xy.last) ** 2)
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

  def is_point?(pt)
    pt.is_a?(Array) and pt.length == 2 and pt.first.is_a?(Numeric) and pt.last.is_a?(Numeric)
  end

end
