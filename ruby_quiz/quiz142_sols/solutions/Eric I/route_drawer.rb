# A component to a solution to RubyQuiz #142 (rubyquiz.com)
# LearnRuby.com
# Released under the Creative Commons Attribution Non-commercial Share
# Alike license (see:
# http://creativecommons.org/licenses/by-nc-sa/3.0/).


begin
  require 'rubygems'
  require 'rmagick'


  # Adds the draw method to the existing Route class that allows the
  # route to be drawn using RMagick.
  class Route
    CircleSize = 0.125
    
    def draw(image_size, file_name)
      image = Magick::Image.new image_size, image_size
      draw = Magick::Draw.new
      
      # scale and translate so origin is lower-left, and we can use Grid
      # coordinates (i.e., [0, 0] -- [n, n])
      scale = image_size.to_f / @size
      draw.translate 0, image_size
      draw.scale scale, -scale
      draw.translate 0.5, 0.5
      
      # draw lines
      
      @points.each_cons(2) do |p1, p2|
        draw.line(p1[0], p1[1], p2[0], p2[1])
      end
      
      # draw line from last point back to first
      draw.push
      draw.stroke 'orange'
      draw.stroke_width 0
      draw.line(@points[0][0], @points[0][1], @points[-1][0], @points[-1][1])
      draw.pop
      
      draw_circle = Proc.new do |p|
        draw.circle(p[0], p[1], p[0], p[1] - CircleSize)
      end
      
      # draw circles
      
      # start is green
      draw.fill('green')
      draw_circle.call @points[0]
      
      # end is red
      draw.fill('red')
      draw_circle.call @points[-1]
      
      # intermediate are black
      draw.fill('black')
      @points[1..-2].each do |p|
        draw_circle.call p
      end
      
      draw.draw image
      image.write file_name
    end
  end
rescue LoadError
end
