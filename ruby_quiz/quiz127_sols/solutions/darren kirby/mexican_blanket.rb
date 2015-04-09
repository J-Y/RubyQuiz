#!/usr/bin/ruby
#
# mexican_blanket.rb - Draw a png image which resembles
# a traditional mexican blanket
#
# Usage:
#  $ mexican_blanket.rb width height colour [colour]...
#
#  width and height are integers
#  colours may be specified by name eg: 'yellow'
#      or by hex code eg: '#FFFF00'
#

require 'RMagick'

COLUMNS = ARGV[0].to_i  # First arg is blanket width in px
ROWS = ARGV[1].to_i     # Second arg is blanket height in px
colours = ARGV[2..-1]   # Remaining args are colours

def mexican_blanket_magic(colours)
  ptr = -1
  pattern = []
  colours.size.times do
    # Next 10 lines build the gradient
    5.times { pattern[ptr += 1] = colours[0] }
    pattern[ptr+=1] = colours[1]

    4.times { pattern[ptr+=1] = colours[0] }
    2.times { pattern[ptr+=1] = colours[1] }

    3.times { pattern[ptr+=1] = colours[0] }
    3.times { pattern[ptr+=1] = colours[1] }

    2.times { pattern[ptr+=1] = colours[0] }
    4.times { pattern[ptr+=1] = colours[1] }

    pattern[ptr+=1] = colours[0]
    5.times { pattern[ptr+=1] = colours[1] }

    # This is our black stripe which divides the gradients
    n = rand(100)
    if n <= 20    # Aprox. 20% chance of 3px wide line
      3.times { pattern[ptr+=1] = "black" }
    elsif n >= 80 # Aprox. 20% chance of 7px wide line
      7.times { pattern[ptr+=1] = "black" }
    end           # Aprox. 60% chance of no line

    # Aprox. 20% chance we will get a diagonal bar
    # of random colour and size (<= 21px)
    if rand(100) < 20
      clr = colours[rand(colours.size)]
      (rand(20)+1).times { pattern[ptr+=1] = clr }
    end

    # Rotate through the colours in order
    cs = colours.shift
    colours.push(cs)
  end

  # Pad out the pattern to match image width
  ptr = -1
  while pattern.size < COLUMNS
    pattern << pattern[ptr+=1]
  end
  return pattern
end

# Create our pattern
pattern = mexican_blanket_magic(colours)

# Create the image canvas
blanket = Magick::Image.new(COLUMNS, ROWS)
stitch = Magick::Draw.new

# This is the plotter. Basically we just
# stamp out a row, left-shift the pattern
# and continue till all the rows are done.
yptr = 0
ROWS.times do
  xptr = 0
  COLUMNS.times do
    stitch.fill(pattern[xptr])  # Set colour
    stitch.point(xptr, yptr)    # Plot point
    xptr += 1
  end
  cc = pattern.shift
  pattern.push(cc)
  yptr += 1
end

# Write the drawing to the canvas,
# and the canvas to a file.

stitch.draw(blanket)
blanket.write("blanket.png")

# end mexican_blanket.rb
