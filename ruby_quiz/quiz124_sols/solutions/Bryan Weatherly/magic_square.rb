# magic_squares.rb
# Ruby Quiz (#124)

class MagicSquare

 def initialize(n)
   raise ArgumentError, "N must be an odd number." if n%2 == 0
   @n = n
   @square = fill
 end

 def fill
   square = Array.new(@n)
   square.each_index { |row| square[row] = Array.new(@n) }
   current = 1
   row = 0
   col = (@n/2+1)-1
   square[row][col] = current
   until current == @n**2
     current+=1
     row = move_down(row)
     col = move_down(col)
     unless square[row][col].nil?
       2.times { |i| row = move_up(row) }
       col = move_up(col)
     end
     square[row][col] = current
   end
   square
 end

 def move_down(val)
   if (val-1) > -1
     val -= 1
   else
     val = (@n-1)
   end
   val
 end

 def move_up(val)
   if (val+1) > (@n-1)
     val = 0
   else
     val += 1
   end
   val
 end

 def display
   header = "+" + "-" * (@n*5-1) + "+"
   puts header
   @square.each do |row|
     current = "| "
     row.each do |col|
       current << " " * ((@n**2).to_s.length - col.to_s.length)
       current << col.to_s + " | "
     end
     puts current
     puts header
   end
 end

end

if __FILE__ == $0
 square = MagicSquare.new(ARGV[0].to_i)
 square.display
end
