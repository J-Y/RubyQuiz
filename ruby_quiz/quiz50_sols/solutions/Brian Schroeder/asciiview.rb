#!/usr/bin/ruby -w
# This is probably the slowest solution to the ruby quiy 
# 
#     "Text Image (#50)"
#     
# http://www.rubyquiz.com/quiz50.html
# 
# It works by finding the letter that best approximates each part of the image.
# The font is specified by files in a subfolder font/ where each letter has its
# own image. The font given here is the terminus font.
#
# The best images result from line images, so I included a preprocessed ducky
# version which was created with image magick using the find_edges.rb program.
#
#
# using the distance function I have here the original ducky image was too
# light, so I created in another preprocessing step a darker grayscale ducky
# that gives a nice ascii rendering.
#
# Blurring the image and/or font images first creates different distance functions
# that give different results.
#
# A third preprocessed version of the duck was created with the (color2gray)[1]
# converter that preserves color differences in grayscale images.
# 
# [1] http://www.cs.northwestern.edu/~ago820/color2gray/
#
require "RMagick"
include Magick

image_preprocessor = lambda do | image | image end
#image_preprocessor = lambda do | image | image.blur_image end
#image_preprocessor = lambda do | image | image.blur_image.blur_image end

#font_preprocessor = lambda do | image | image end
#font_preprocessor = lambda do | image | image.blur_image end
font_preprocessor = lambda do | image | image.blur_image.blur_image end
#font_preprocessor = lambda do | image | image.blur_image.blur_image.blur_image end

# Width of output in characters
width = 78

# Load precalculated Font images from font directory
font = {}
Dir['font/*.png'].each do | file |
  font[file[/\d+/].to_i] = font_preprocessor[Image.read(file).first.quantize(256, Magick::GRAYColorspace)]
end

font_size = [font.values.first.columns, font.values.first.rows]

# Load Image Using RMagick
image_name = ARGV[0] || "Ducky.png"
image = Image.read(image_name).first.quantize(256, Magick::GRAYColorspace).normalize
# Make image size a multiple of the font_size
#image = image.resize((image.columns.to_f / font_size[0]).ceil * font_size[0],
#                     (image.rows.to_f / font_size[1]).ceil * font_size[1])
                     
# Resize image to output size
image = image.resize(width * font_size[0],
                     (((image.rows.to_f / image.columns.to_f) * width * font_size[0]) / font_size[1]).ceil * font_size[1])

# Blur image for a better distance function
image = image_preprocessor[image]

# Calculate Distance between a part of the original image and a font symbol
# This could be something a lot more advanced like a distance measure using
# edge comparision
def distance(i1, i2)
  return i1.difference(i2)
end

# Print the ascii image by finding the most similar font symbol for each 
# part of the image
0.step(image.rows-1, font_size[1]) do | row |
  0.step(image.columns-1, font_size[0]) do | col |
    part = image.crop(col, row, font_size[0], font_size[1])
    char = font.map { | char, char_img |
	     [distance(char_img, part), char]
	   }.min[1]
    print char.chr
  end
  puts
end
