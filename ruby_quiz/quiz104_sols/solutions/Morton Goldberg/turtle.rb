# An implementation of Turtle Procedure Notation (TPN) as described in
# H. Abelson & A. diSessa, "Turtle Geometry", MIT Press, 1981.
#
# Turtles navigate by traditional geographic coordinates: X-axis pointing
# east, Y-axis pointing north, and angles measured clockwise from the
# Y-axis (north) in degrees.

class Turtle
   include Math
   DEG = Math::PI / 180.0
   ORIGIN = [0.0, 0.0]

   alias run instance_eval
   attr_accessor :track
   attr_reader :xy, :heading

   def degree
      DEG
   end

   ###
   # Turtle primitives
   ###

   # Place the turtle at [x, y]. The turtle does not draw when it changes
   # position.
   def xy=(coords)
      if coords.size != 2
         raise(ArgumentError, "turtle needs two coordinates")
      end
      x, y = coords
      must_be_number(x, 'x-coordinate')
      must_be_number(y, 'y-coordinate')
      @xy = x.to_f, y.to_f
   end

   # Set the turtle's heading to <degrees>.
   def heading=(degrees)
      must_be_number(degrees, 'heading')
      @heading = degrees.to_f
      case
      when @heading >= 360.0
         @heading -= 360.0 while @heading >= 360.0
      when @heading < 0.0
         @heading += 360.0 while @heading < 0.0
      end
      @heading
   end

   # Raise the turtle's pen. If the pen is up, the turtle will not draw;
   # i.e., it will cease to lay a track until a pen_down command is given.
   def pen_up
      @pen = :up
   end

   # Lower the turtle's pen. If the pen is down, the turtle will draw;
   # i.e., it will lay a track until a pen_up command is given.
   def pen_down
      @pen = :down
      @track << [@xy]
   end

   # Is the pen up?
   def pen_up?
      @pen == :up
   end

   # Is the pen down?
   def pen_down?
      @pen == :down
   end

   ###
   # Turtle commands
   ###

   # Place the turtle at the origin, facing north, with its pen up.
   # The turtle does not draw when it goes home.
   def home
      pen_up
      self.xy = ORIGIN
      self.heading = 0.0
   end

   # Home the turtle and empty out it's track.
   def clear
      home
      self.track = []
   end

   alias initialize clear

   # Turn right through the angle <degrees>.
   def right(degrees)
      must_be_number(degrees, 'turn')
      self.heading = heading + degrees.to_f
   end

   # Turn left through the angle <degrees>.
   def left(degrees)
      right(-degrees)
   end

   # Move forward by <steps> turtle steps.
   def forward(steps)
      must_be_number(steps, 'distance')
      angle = heading * DEG
      x, y = xy
      self.xy = [x + steps * sin(angle), y + steps * cos(angle)]
      track.last << xy if pen_down?
   end

   # Move backward by <steps> turtle steps.
   def back(steps)
      forward(-steps)
   end

   # Move to the given point.
   def go(pt)
      self.xy = pt
      track.last << xy if pen_down?
   end

   # Turn to face the given point.
   def toward(pt)
      x2, y2 = pt
      must_be_number(x2, 'pt.x')
      must_be_number(y2, 'pt.y')
      x1, y1 = xy
      set_h(90.0 - atan2(y2 - y1, x2 - x1) / DEG)
   end

   # Return the distance between the turtle and the given point.
   def distance(pt)
      x2, y2 = pt
      must_be_number(x2, 'pt.x')
      must_be_number(y2, 'pt.y')
      x1, y1 = xy
      hypot(x2 - x1, y2 - y1)
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

   # Raise an exception if <val> is not a number.
   def must_be_number(val, name)
      if !val.respond_to?(:to_f)
         raise(ArgumentError, "#{name} must be a number")
      end
   end
end
