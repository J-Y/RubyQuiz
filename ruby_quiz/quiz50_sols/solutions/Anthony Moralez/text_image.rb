require 'RMagick'

class ImageToAscii
@@ascii_pixel = [ Array.new(10, '#'),
Array.new(35, '.'),
Array.new(5, '\\'),
Array.new(15, '-'),
Array.new(20, '*'),
Array.new(15, '+'),
Array.new(20, ':'),
Array.new(20, '/'),
Array.new(30, '='),
Array.new(30, '|'),
Array.new(30,'@'),
Array.new(30, ' ')].flatten!
def initialize( image )
@image = image
end
def convert
prepare_image
translate_pixels
end
def translate_pixels
pixels = @image.get_pixels(0, 0, @image.columns, @image.rows)
new_pixels = pixels.map { |pix| to_ascii pix.intensity}
0.upto(@image.rows) do |row|
new_pixels.insert( (row*@image.columns+row), "\n")
end
new_pixels
end
def prepare_image
@image = @image.blur_image.blur_image.scale(40,40)
end
def to_ascii( index )
@@ascii_pixel[index]
end
end

img = Magick::ImageList.new(ARGV[0])
converter = ImageToAscii.new(img)
puts converter.convert.to_s
