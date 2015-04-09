#---------------------------------------------------------------------#
#                                                                     #
#  Program   : Fractals (Ruby Quiz #125)                              #
#  Author    : David Tran                                             #
#  Date      : 2007-05-30                                             #
#  Blog      : http://davidtran.doublegifts.com/blog/?p=48            #
#  Reference : http://mathworld.wolfram.com/PerpendicularVector.html  #
#  Note      : Using vector calculation to compute each level's       #
#              points. The first level line can be in any direction.  #
#                                                                     #
#---------------------------------------------------------------------#
require 'enumerator'
require 'RMagick'

LEVEL_0 = [[0, 0], [350, 200]]

def next_level(polylines)
 polylines.enum_cons(2).inject([polylines.first]) do |array, (p1, p2)|
   x1, y1 = p1
   x2, y2 = p2
   a = (x2 - x1) / 3.0
   b = (y2 - y1) / 3.0
   array << [x1+a, y1+b] << [x1+a-b, y1+b+a] <<
     [x1+2*a-b, y1+2*b+a] << [x1+2*a, y1+2*b] << p2
 end
end

exit unless __FILE__ == $0
imageList = Magick::ImageList.new
level = LEVEL_0
(ARGV[0].to_i + 1).times do |i|
 level = next_level(level) if i > 0
 image = Magick::Image.new(400, 300)
 image.delay = 100
 draw = Magick::Draw.new
 draw.fill_opacity(0)
 draw.stroke('black')
 draw.polyline(*level)
 draw.text(300,100,"level #{i}")
 draw.draw(image)
 imageList << image
end
imageList.write(File.basename($0) + ".gif")
