#!/usr/bin/env ruby
# Ruby Quiz 125: Fractals
# fractals.rb
#
# Usage: ./fractals.rb LEVEL [-l0 LEVEL_0] [-l1 LEVEL_1] \
#                      [-format turtle | text | display | IMG_FORMAT]
#
# LEVEL: an integer >= 0.
# LEVEL_0 and LEVEL_1: turtle-graphics strings describing the first two levels
#                      of the fractal (defaults: F & FLFRFRFLF).
#
# Formats (default: text):
#   turtle:     Print out a turtle-graphics string of Fs, Ls, and Rs.
#   text:       Print out a textual representation of the fractal.
#   display:    Use RMagick to display the image.
#   IMG_FORMAT: An image format like png, jpg, or gif that RMagick understands.

DefaultLevel0 = 'F'
DefaultLevel1 = 'FLFRFRFLF'
DefaultFormat = 'text'

class Fractal
  # Create a new fractal from the givel level_0 and level_1 turtle strings.
  def initialize level_0, level_1
    @level_0 = level_0
    @level_0_byte = level_0[0] # Just to keep from re-calculating it over & over
    @level_1 = level_1
    self
  end

  # Return the turtle string for drawing the fractal to the given level.
  def turtle level
    if level.zero?   then @level_0
    elsif level == 1 then @level_1
    else
      s = ''
      @level_1.each_byte do |b|
        b == @level_0_byte ? s += turtle(level-1) : s += b.chr
      end
      s
    end
  end
end

if __FILE__ == $0
  # Read arguments.
  level = ARGV.first.to_i

  i = ARGV.index '-l0'
  lev0 = (i.nil? ? DefaultLevel0 : ARGV[i+1].upcase)
  i = ARGV.index '-l1'
  lev1 = (i.nil? ? DefaultLevel1 : ARGV[i+1].upcase)

  i = ARGV.index '-format'
  format = (i.nil? ? DefaultFormat : ARGV[i+1])

  # Build the turtle-graphics string of the fractal.
  turtle = Fractal.new(lev0, lev1).turtle level

  # Output.
  if format == 'turtle'
    puts turtle
  elsif format == 'text'
    require 'turtle_text'
    puts TurtleText.textize(turtle)
  else
    require 'turtle_image'
    image = TurtleImage.new turtle
    if format == 'display'
      image.display
    else
      begin
        filename = "fractal_#{lev0}_#{lev1}_#{level}.#{format}"
        image.write filename
        puts "Wrote level-#{level} fractal to #{filename}"
      rescue Exception => ex
        $stderr.puts "There was an error writing the image to #{filename}"
        $stderr.puts "Are you sure the format '#{format}' is valid?"
        $stderr.puts "(#{ex})"
      end
    end
  end
end
