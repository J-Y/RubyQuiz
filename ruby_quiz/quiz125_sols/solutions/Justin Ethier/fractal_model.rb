=begin
Justin Ethier
May 2007
Solution to: http://www.rubyquiz.com/quiz125.html

This file contains the fractal model class. The basic idea is that 
it will create a list of values corresponding to the direction of
the next line of the fractal. There are 4 possible directions (angles):

 |        090
- -   180     000
 |        270

And, for example, here are some possible lists:
 
000 090 000 270 000 (RURDR, no rotation)
090 180 090 000 090 (ULURU, 90 degree rotation, x = (x + 90) % 360)
270 000 270 180 270 (DRDLD, -90 degree rotation, x = (x - 90) % 360)

With this list, a program can draw the fractal by simply following
these traces, just like drawing without lifting your pen from the paper.
=end

class FractalModel

  def initialize()
    # This defines the overall shape of the fractal (at level 1)
    @base_fractal = [0, 90, 0, 270, 0]
  end

  # Build a list of lines to trace for the fractal, based on
  # the given depth level
  def build(level)
    # Build list of lines to draw
    # First level is base fractal, no offset rotation
    fractal_list = []
    rec_build(level, @base_fractal[0], 0, fractal_list)
    
    return fractal_list
  end
  
  # Recursively build the fractal
  def rec_build(level, direction, rotation, fractal_list)
    # At the lowest level, add an actual piece to the array
    if (level == 0)
      fractal_list.push((direction + rotation) % 360)
      return
    end
    
    # At higher levels, we need to define the shape of the fractal
    for piece_direction in @base_fractal
      rec_build(
        level - 1,        # Drilling down to next lower level
        piece_direction,  # Direction at that level
        (direction + rotation) % 360, # Direction at this level becomes rotation of lower level
        fractal_list) # Append to the list
    end
  end
end

