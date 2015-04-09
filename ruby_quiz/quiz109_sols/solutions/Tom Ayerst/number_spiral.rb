class SpiralMaker
 def make_spiral(square_size)
   # allow for even numbered squares by missing off the last row and column
   size = square_size
   if (square_size.modulo(2) == 0)
     square_size = square_size+1
   end
     #step along row
   (1..size).each do |y|
     # step down columns
     (1..size).each do |x|
       # are we in top left or bottom right half of spiral?
       if (y+x <= square_size)          # top left - calculate value
         sn = square_size - (2 * (min(x,y) - 1))
         val = (sn*sn) - (3*sn) + 2 - y + x
       else           # bottom right - calculate value
         sn = square_size - (2 * (square_size - max(x,y)))
         val = (sn*sn) - sn + y - x
       end
       # Print value
       STDOUT.printf "%03d ", val
     end
     # Next line
     STDOUT.print "\n"
   end
 end
 def min(a,b)
   (a <= b) ? a : b
 end
 def max(a,b)
   (a >= b) ? a : b
 end
end

maker = SpiralMaker.new
maker.make_spiral 3
