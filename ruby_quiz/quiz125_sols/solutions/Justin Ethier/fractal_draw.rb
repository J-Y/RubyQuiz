=begin
Justin Ethier
May 2007
Solution to: http://www.rubyquiz.com/quiz125.html

This file contains the fractal drawing class. The purpose
of this class is to take a list of directions from the
FractalModel class and draw them.
=end

require 'fractal_model.rb'
require 'RMagick'
include Magick

class FractalGfxDraw

  # Draw the given list of fractal traces to file
  def draw(level, fractal_list, filename)
    width  = 8 * (3 ** level) # Rough approximation
    height = 5 * (3 ** level) # Rough approximation
    
    canvas = Magick::ImageList.new
    canvas.new_image(width, height, Magick::HatchFill.new('white', 'white')) #'gray90'))

    # Draw the fractal
    fill_canvas(canvas, fractal_list, width, height)
    
    # Write to file
    canvas.write(filename)  
  end
  
  # Fill the given canvas with fractal traces
  def fill_canvas(canvas, fractal_list, width, height)
    cur_pt = [0, 0] # x, y
    new_pt = [0, 0] # x, y
    
    # Settings for lines of the fractal
    line_len = 8
    line = Magick::Draw.new
    line.stroke('green') #tomato')
    line.fill_opacity(0)
    line.stroke_opacity(0.75)
    line.stroke_width(2)

    # Draw the fractal line-by-line
    for dir in fractal_list
      
        # Move the cursor
        if dir == 0
          new_pt[0] = new_pt[0] + line_len
        elsif dir == 90
          new_pt[1] = new_pt[1] + line_len
        elsif dir == 180
          new_pt[0] = new_pt[0] - line_len
        elsif dir == 270
          new_pt[1] = new_pt[1] - line_len
        end
        
        # Draw the line
        line.line(width - cur_pt[0], height - line_len - cur_pt[1], 
                  width - new_pt[0], height - line_len - new_pt[1])

        # Move cursor to the next point
        cur_pt[0] = new_pt[0]
        cur_pt[1] = new_pt[1]        
    end
    
    # Draw all lines to canvas
    line.draw(canvas)
  end
end


fract = FractalModel.new
gfx = FractalGfxDraw.new

# Get level from the CMD line
level    = ARGV[0] != nil ? ARGV[0].to_i : 3 # Default
filename = ARGV[1] != nil ? ARGV[1] : "output.jpg"

# Build fractal
list = fract.build(level)

# Render the fractal to file
gfx.draw(level, list, filename)
