#!/usr/bin/env ruby
# Ruby Quiz 127: Mexican Blanket
# mexican_blanket.rb
#
# Usage: mexican_blanket.rb WIDTH HEIGHT [--symmetric | --color-symmetric]
#                                        [--format FORMAT]
#
# WIDTH:  The width of the blanket.
# HEIGHT: The height of the blanket.
# --symmetric:       The blanket should be pattern-but-not-color-symmetric.
# --color-symmetric: The blanket should be pattern-and-color-symmetric.
#
# Formats (default: text):
#   text:       Print out a textual representation of the blanket.
#   display:    Use RMagick to display the image.
#   IMG_FORMAT: An image format like png, jpg, or gif that RMagick understands.

require 'blanket'

if __FILE__ == $0
  width, height = ARGV[0].to_i, ARGV[1].to_i

  if ARGV.include? '--symmetric'
    blanket = Blanket.new(width, height, true, false)
  elsif ARGV.include? '--color-symmetric'
    blanket = Blanket.new(width, height, true, true)
  else
    blanket = Blanket.new(width, height)
  end

  i = ARGV.index '--format'
  format = (i.nil? ? 'text' : ARGV[i+1])

  if format == 'text'
    puts blanket
  else
    require 'blanket_image'
    image = BlanketImage.new blanket
    if format == 'display'
      image.display
    else
      begin
        filename = "blanket_#{width}x#{height}.#{format}"
        image.write filename
        puts "Wrote blanket to #{filename}"
      rescue Exception => ex
        $stderr.puts "There was an error writing the image to #{filename}"
        $stderr.puts "Are you sure the format '#{format}' is valid?"
        $stderr.puts "(#{ex})"
      end
    end
  end
end
