# Here is my solution to the quiz. Looking at the pattern for a moment, each
# line of the pattern is really just the previous line, shifted over one
# pixel. Thus to draw the pattern we can first calculate what all of the
# pixels will be. Then we simply iterate over this list, drawing one line at a
# time. With that in mind, here is the code I used to create the gradient:

def create_gradient(colors, width=5)
 pattern = []

 for i in 0...(width)
   (width-i).times { pattern.push(colors[0]) }
   (i+1).times { pattern.push(colors[1]) }
 end

 for i in 0...(width)
   (i+1).times { pattern.push(colors[2]) }
   (width-i-1).times { pattern.push(colors[1]) }
 end

 pattern
end

# And this function creates solid bands of color:

def create_solid(colors, width)
 pattern = []
 for color in colors
   width.times { pattern.push(color) }
 end
 pattern
end

# To draw ASCII we simply print each line in turn.

def draw_ascii(pattern, width)
 for i in 0...(pattern.size-width+1)
   puts pattern.slice(i, width).join
 end
end

# And to draw a JPEG we get a bit fancier, but its the same basic idea. There
# must be a better way to code this, because it takes much too long to run.
# But anyway, here it is:

require 'RMagick'
include Magick

def draw(filename, pattern, width, height)
 canvas = Magick::ImageList.new
 canvas.new_image(width, height, Magick::HatchFill.new('white', 'white'))
 pts = Magick::Draw.new

 for y in 0... height
   line = pattern.slice(y, width)

   x = 0
   for color in line
     pts.fill(color)
     pts.point(x, y)
     x = x + 1
   end
 end

 pts.draw(canvas)
 canvas.write(filename)
end

# Finally, we draw the ASCII from the Quiz and a picture similar to the one
# that was posted.

# 1) Draw the ASCII representation
draw_ascii(create_gradient(['R', 'B', 'Y']), 28)

# 2) Draw a picture of the blanket
mex_flag = create_solid(['rgb(0, 64, 0)', 'white', 'red'], 5)
border = create_solid(['rgb(0, 64, 0)'], 25)

pattern = create_gradient(['red', 'blue', 'yellow'])
pattern = pattern + mex_flag
pattern = pattern + border
pattern = pattern + create_gradient(['black', 'red', 'orange'])
pattern = pattern + border
pattern = pattern + mex_flag.reverse
pattern = pattern + create_gradient(['red', 'purple', 'black'], 8)
draw("mexican_blanket.jpg", pattern, 100, 200)

# Here is a picture of the final blanket, if anyone is interested:
# http://justin.ethier.googlepages.com/mexican_blanket.jpg
