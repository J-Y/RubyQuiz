# Ruby Quiz 125: Fractals
# turtle.rb

# Miscellaneous turtle-graphics stuff.
module Turtle
  Up, Left, Right, Down = (0..3).to_a # absolute directions

  # Yield once for each absolute direction moved in when following the given
  # turtle string. abs_dir is the initial absolute direction.
  def Turtle.each_absolute_direction turtle, abs_dir = Right
    turtle.each_byte do |b|
      rel_dir = b.chr
      # Perhaps some trig would be better than all these ifs?
      if abs_dir == Up
        if    rel_dir == 'L' then abs_dir = Left
        elsif rel_dir == 'R' then abs_dir = Right end
      elsif abs_dir == Right
        if    rel_dir == 'L' then abs_dir = Up
        elsif rel_dir == 'R' then abs_dir = Down end
      elsif abs_dir == Down
        if    rel_dir == 'L' then abs_dir = Right
        elsif rel_dir == 'R' then abs_dir = Left end
      else # abs_dir == Left
        if    rel_dir == 'L' then abs_dir = Down
        elsif rel_dir == 'R' then abs_dir = Up end
      end

      yield(abs_dir) if rel_dir == 'F'
    end
  end

  # Return an array of two arrays, each containing the coords of the lower-left
  # corner and the upper-right corner of the given turtle string.The initial
  # coordinate is [0, 0]. Each segment has a length of 1.
  def Turtle.corners turtle
    min_x = max_x = min_y = max_y = 0
    last_x = last_y = 0
    each_coord(turtle, false) do |x, y|
      min_x = x if x < min_x; max_x = x if x > max_x
      min_y = y if y < min_y; max_y = y if y > max_y
      last_x, last_y = x, y
    end
    [[min_x, min_y], [max_x, max_y]]
  end

  # Yield once for each x,y coordinate for the given string. The coord is an
  # array of two numbers. The initial coordinate is [0, 0]. Each segment has a
  # length of 1.
  def Turtle.each_coord turtle, yield_first = true
    abs_dir = Right
    x = y = 0
    yield([x, y]) if yield_first

    each_absolute_direction(turtle) do |abs_dir|
      if    abs_dir == Up    then y += 1
      elsif abs_dir == Right then x += 1
      elsif abs_dir == Down  then y -= 1
      else                        x -= 1 end # abs_dir == Left
      yield [x, y]
    end
  end
end
