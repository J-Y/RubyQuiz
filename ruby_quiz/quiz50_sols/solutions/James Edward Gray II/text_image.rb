#!/usr/local/bin/ruby -w

unless ARGV.size == 1 and File.exists? ARGV.first
	puts "Usage:  #{File.basename($0)} IMAGE_FILE"
	exit
end

require "RMagick"

text = %w{. : - ^ ! * + " = % o # \\ $ < &}

image = Magick::Image.read(ARGV.shift).first

image = image.quantize(text.size)
image.scale!([39.0 / image.columns, 20.0 / image.rows].min)
image = image.quantize(text.size)

pixels = Array.new
0.upto(image.rows) do |y|
	0.upto(image.columns) do |x|
		pixel = image.pixel_color(x, y).intensity
		pixels << pixel unless pixels.include? pixel
	end
end
pixels.sort! { |a, b| b <=> a }

0.upto(image.rows) do |y|
	0.upto(image.columns) do |x|
		2.times { print text[pixels.index(image.pixel_color(x, y).intensity)] }
	end
	puts
end
