#! /usr/bin/env ruby
#
# Marcel Ward   <wardies ^a-t^ gmaildotcom>
# Sunday, 14 January 2007
# Solution for Ruby Quiz number 109 - Number Spiral

# Prints a clockwise spiral, starting with zero at the centre (0,0).
# Note, here x increases to the east and y increases to the north.
def spiral(size)
 # maximum -ve/+ve reach from the centre point "0" at (0,0)
 neg_reach = -pos_reach = size/2
 # we miss out the bottom/left sides for even-sized spirals
 neg_reach += 1 if size % 2 == 0

 # Compute width to allocate a cell based on the max value printed
 cell_width = (size**2 - 1).to_s.size + 3

 pos_reach.downto(neg_reach) do
   |y|
   spiral_line((neg_reach..pos_reach), y, cell_width)
 end
end

def spiral_line(x_range, y, cell_width)
 x_range.each do
   |x|
   print spiral_value_at(x, y).to_s.center(cell_width)
 end
 puts
end

# calculate the value in the spiral at location (x,y)
def spiral_value_at(x, y)
 if x + y > 0  # top/right side
   if x > y    # right side
     4 * x**2 - x - y
   else        # top side
     4 * y**2 - 3 * y + x
   end
 else          # bottom/left side
   if x < y    # left side
     4 * x**2 - 3 * x + y
   else        # bottom side
     4 * y**2 - y - x
   end
 end
end

spiral(10)
