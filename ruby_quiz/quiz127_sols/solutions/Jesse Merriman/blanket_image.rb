# Ruby Quiz 127: Mexican Blanket
# blanket_image.rb

require 'blanket'
require 'RMagick'
include Magick

class BlanketImage < Magick::Image
  # Colors from http://library.thinkquest.org/05aug/01280/Images/flag.jpg
  # Not sure how accurate that is though..
  StringToColor = { 'R' => '#fe0000', 'B' => '#0333a1', 'Y' => '#ffff49',
                    'O' => '#ea6520', 'G' => '#039e36', 'W' => '#ffffff' }

  def initialize blanket
    super blanket.width, blanket.height
    draw_blanket blanket
    self
  end

  def draw_blanket blanket
    pixels = []
    blanket.each_row_with_index do |row, y|
      row.split(//).each do |color_char|
        pixels << Magick::Pixel.from_color(StringToColor[color_char])
      end
    end
    store_pixels 0, 0, blanket.width, blanket.height, pixels
  end
end
