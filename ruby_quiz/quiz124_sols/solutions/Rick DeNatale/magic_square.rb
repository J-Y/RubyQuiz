require 'narray'
# Based on
# http://mathworld.wolfram.com/MagicSquare.html
#
# and
#
# http://en.wikipedia.org/wiki/Magic_square
#
class MagicSquare
 def initialize(n)
   raise ArgumentError.new("Invalid order #{n}") if n < 1 || n == 2
   @order = n
   @contents = NArray.int(n,n)
   case
   when n % 4 == 0
     generate_doubly_even
   when n % 2 == 0
     generate_singly_even
   else
     generate_odd
   end
 end

 def [](row,col)
   @contents[row,col]
 end

 def []=(row,col,val)
   @contents[row,col] = val
 end

 def is_magic?
   magic_constant = (order**3 + order) / 2
   each_row do |r|
     return false unless magic_constant == r.inject {|sum, e| sum + e}
   end
   each_col do |r|
     return false unless magic_constant == r.inject {|sum, e| sum + e}
   end
   each_diag do |r|
     return false unless magic_constant == r.inject {|sum, e| sum + e}
   end
   true
 end

 def each_row
   for row in (0...order)
     yield @contents[0..-1,row].to_a
   end
 end

 def each_col
   for col in (0...order)
     yield @contents[col, 0..-1].to_a
   end
 end

 def each_diag
   diag1 = []
   diag2 = []
   for i in (0...order)
     diag1 << self[i,i]
     diag2 << self[i, order-(i+1)]
   end
   yield diag1
   yield diag2
 end

 def to_s
   iw = (1 + Math.log10(order*order)).to_i
   h = "#{"+-#{'-'*iw}-"*order}+"
   fmt = " %#{iw}d |" * order
   r = [h]
   each_row do |row|
     r << "|#{fmt % row}"
   end
   r << h
   r.join("\n")
 end

 attr_reader :order

 # generate an odd order magic square using siamese method
 def generate_odd
   # start with first row, middle column
   x = order / 2
   y = 0
   total_squares = order*order
   for i in (1..total_squares)
     self[x,y]=i
     new_x = (x+1) % order
     new_y = (y-1) % order
     self[x,y]=i
     x, y = *((self[new_x, new_y] == 0) ? [new_x, new_y] : [x, (y+1) % order] )
   end
 end

 # generate magic square whose order is a multiple of 4
 def generate_doubly_even
   # First fill square sequentially
   for y in (0...order)
     for x in (0...order)
	self[x,y] = 1 + y*order + x
     end
   end
   # now replace elements on the diagonals of 4x4 subsquares
   # with the value of subtracting the intial value from n^2 + 1
   # where n is the order
   pivot = order*order + 1
   (0...order).step(4) do |x|
     (0...order).step(4) do |y|
	for i in (0..3) do
	  self[x+i, y+i] = pivot - self[x+i,y+i]
	  self[x+i, y+3-i] = pivot - self[x+i,y+3-i]
	end
     end
   end
 end

 # Generate magic square whose order is a multiple of 2 but not 4
 # using Conway's method
 def generate_singly_even
   m = (order - 2)/4
   l = [[1,0], [0,1], [1,1], [0,0]]
   u = [[0,0], [0,1], [1,1], [1, 0]]
   x = [[0,0], [1,1], [0,1], [1, 0]]
   # the mathworld article uses the expression
   # 2m + 1 for the generator magic square
   # but it can be easily shown that this is equal
   # to order/2 which makes the code more understandable
   pat_order = order/2
   prototype = self.class.new(pat_order)
   for p_row in (0...pat_order)
     for p_col in (0...pat_order)
	deltas =
	  case
	  when p_row < m
	    l
	  when p_row == m
	    p_col == m ? u : l
	  when p_row == m + 1
	    p_col == m ? l : u
	  else
	    x
	  end
	base = 1 + (prototype[p_col,p_row] - 1) * 4
	deltas.each_with_index do |dxdy, i|
	  dx, dy = *dxdy
	  self[p_col*2 + dx, p_row*2 + dy] = base + i
	end
     end
   end
 end
end
