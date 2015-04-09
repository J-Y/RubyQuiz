#!/usr/bin/ruby -w

require "RMagick"
include Magick

image_name = ARGV[0] || "Ducky.png"
image = Image.read(image_name).first.modulate(1.0, 0.0, 1.0)

32.upto(126) do | t |
  target = Image.new(7, 14) 
  gc = Magick::Draw.new
  gc.font( ARGV[1] || "{-*-terminus-*-r-*--14-*-*-*-*-*-*-15}" )
  gc.gravity = Magick::NorthWestGravity
  gc.text(0, -2, "'#{t.chr}'")
  gc.draw(target) rescue ""
  target.write("font/%03i.png" % t)
end
