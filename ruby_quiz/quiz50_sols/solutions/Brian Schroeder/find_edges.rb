#!/usr/bin/ruby
#
require "RMagick"

image_name = ARGV[0] || "Ducky.png"

image = Magick::Image.read(image_name).first.despeckle.despeckle.despeckle.
  blur_image.blur_image.blur_image.
  edge

image.channel(Magick::RedChannel).
  composite(image.channel(Magick::GreenChannel), 0, 0, Magick::PlusCompositeOp).
  composite(image.channel(Magick::BlueChannel), 0, 0, Magick::PlusCompositeOp).
  negate.
  bilevel_channel(90 * Magick::MaxRGB / 100).
  despeckle.
  write("edges_#{image_name}")
