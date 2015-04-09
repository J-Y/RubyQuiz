require 'matrix'

# Class helpers
class Array
   def tail
      self[1..-1]
   end
   def mod_fetch i
      self[i % size]
   end
   def each_pair
      each_with_index do |a, i|
         yield a, self[i+1] if i+1 < size
      end
   end
end

class Vector
   def x
      self[0]
   end

   def y
      self[1]
   end

   def len
      Math.sqrt(inner_product(self))
   end

   def rot90
      Vector[-y, x]
   end

   def rot45   # cheap rotate by 45 degrees
      Vector[x - y, x + y]
   end

   def to_s
      "#{x} #{y}"
   end
end

# Postscript class (what a hack!)
class PS
   def initialize(&block)
      @cmds = []
      instance_eval(&block) if block
   end

   def push(*args, &block)
      @cmds << args.join(' ')
      @cmds << instance_eval(&block) if block
   end

   def to_s
      @cmds.join("\n")
   end

   def page(&block)
      instance_eval(&block)
      push 'showpage'
   end

   def path(&block)
      push 'newpath'
      instance_eval(&block)
   end

   def gsave(&block)
      push 'gsave'
      instance_eval(&block)
      push 'grestore'
   end

   def method_missing(name, *args)
      push *args + [name]
   end
end

# Constants and helper funcs for building image data
Basis = [Vector[1, 0], Vector[0, -1], Vector[-1, 0], Vector[0, 1]]
Shade = [0.3, 0.5, 0.7]

def fibo(n)
   a, b = 1, 1
   n.times { a, b = b, a + b }
   a
end

def spiral(n)
   if n.zero?
      Vector[0, 0]
   else
      i = n - 1
      spiral(i) + Basis.mod_fetch(i) * fibo(i)
   end
end



# Build list of spiral coordinates
steps = (ARGV[0] || 11).to_i
coords = (0..steps).map { |i| spiral(i).rot45 }

# Calculate page/content dimensions, scale and center
inch   = 72
margin = 0.5 * inch
pagew  = 8.5 * inch
pageh  =  11 * inch
contw  = pagew - 2 * margin
conth  = pageh - 2 * margin

xmin = coords.min { |a, b| a.x <=> b.x }.x
xmax = coords.max { |a, b| a.x <=> b.x }.x
ymin = coords.min { |a, b| a.y <=> b.y }.y
ymax = coords.max { |a, b| a.y <=> b.y }.y

scale = [contw / (xmax - xmin), conth / (ymax - ymin)].min

cx = (pagew - (xmax - xmin.abs) * scale) / 2
cy = (pageh - (ymax - ymin.abs) * scale) / 2

# Scale coords to fill page
coords.map! { |v| v * scale }

# Build Postscript image
doc = PS.new do
   def box a, b
      l, r = [a.x, b.x].min, [a.x, b.x].max
      b, t = [a.y, b.y].min, [a.y, b.y].max

      moveto l, b
      lineto r, b
      lineto r, t
      lineto l, t
      closepath
   end

   page do
      translate cx, cy

      i = 0
      coords.each_pair do |a, b|
         path do
            box a, b
            gsave do
               setgray Shade.mod_fetch(i += 1)
               fill
            end
            stroke
         end
      end

      setrgbcolor 0.8, 0.4, 0
      path do
         moveto coords.first
         angle = 180
         coords.each_pair do |a, b|
            d  = (a + b) * 0.5
            d += (a - d).rot90
            arcn d, (d - a).len, angle, (angle -= 90)
         end
         stroke
      end
   end
end

puts doc
