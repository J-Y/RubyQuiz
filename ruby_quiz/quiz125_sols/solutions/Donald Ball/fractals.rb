# Ruby Quiz 125
# Donald Ball
# version 1.0

DIRECTIONS = [:east, :south, :west, :north]

def instructions(level=1, list=[:forward])
  if level == 1
    list 
  else
    instructions(level-1, list.map do |item|
      case item
        when :forward
          [:forward, :left, :forward, :right, :forward, :right, :forward, :left, :forward]
        else item
      end
    end.flatten)
  end
end

def plot(instructions)
  p = [0, 0]
  points = [p]
  direction = :east
  instructions.each do |item|
    case item
      when :forward
        p = p.dup
        case direction
          when :east: p[0] += 1
          when :south: p[1] -= 1
          when :west: p[0] -= 1
          when :north: p[1] += 1
        end
        points << p
      when :left: direction = DIRECTIONS[(DIRECTIONS.index(direction) - 1) % 4]
      when :right: direction = DIRECTIONS[(DIRECTIONS.index(direction) + 1) % 4]
    end
  end
  points
end

def to_html(points, width=600, height=400)
  length = [width/points.map {|p| p[0]}.max, height/points.map {|p| p[1]}.max].min
  points.map! {|p| p.map {|x| x*length}}
  s = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" '
  s << '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  s << "\n<html><head>"
  s << "<script type='text/javascript'>\n"
  s << "<!--\n"
  s << "function draw() {\n"
  s << "var context = document.getElementById('canvas').getContext('2d');\n"
  s << "context.lineWidth = 1;\n"
  s << "context.strokeStyle = '#ff0000';\n"
  s << "context.beginPath();\n"
  p = points.shift
  s << "context.moveTo(#{p[0]},#{p[1]});\n"
  points.each {|p| s << "context.lineTo(#{p[0]}, #{p[1]});\n" }
  s << "context.stroke();\n"
  s << "}\n"
  s << "//-->\n"
  s << "</script>"
  s << "<body onload='draw()'>"
  s << "<canvas id='canvas' width='#{width}' height='#{height}'></canvas>"
  s << "</body></html>"
  s
end

if $0 == __FILE__
  puts to_html(plot(instructions(ARGV[0].to_i))) if ARGV.length == 1
end