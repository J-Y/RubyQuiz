# Ruby Quiz 125: Fractals
# turtle_image.rb

require 'turtle_draw'
require 'RMagick'

# This class isn't really necessary, what with TurtleDraw doing the hard work.
# It just sets up some attributes and uses a TurtleDraw to draw on itself.
class TurtleImage < Magick::Image
  BGColor = 'black'
  Border  = 10 # pixels

  # Create a new TurtleImage from the given string.
  def initialize turtle
    draw = TurtleDraw.new turtle, Border, Border
    width  = draw.max_x - draw.min_x + 2*Border
    height = draw.max_y - draw.min_y + 2*Border
    super(width, height) { self.background_color = BGColor }
    draw.draw self
    self
  end
end
