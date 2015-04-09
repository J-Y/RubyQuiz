class Board
   def initialize(size)
       @board = Array.new(size) { Array.new(size) { '.' } }
       @size = size
       @current = 1
   end

   #Checks if the spot at (x, y) is available
   def available?(x, y)
       if x >= 0 and x < @size and y >= 0 and y <= @size
           @board[x][y] == '.'
       else
           false
       end
   end

   #Returns a list of pairs which can be reached from (x, y)
   def available_from(x, y)
       available = [[x, y - 3], [x + 2, y - 2], [x + 3, y], [x + 2, y + 2], [x, y + 3], [x - 2, y + 2], [x - 3, y],[x - 2, y - 2]].map { |pair| available?(*pair) ? pair : nil }.compact
   end

   #Checks if the board is completed
   def full?
       @size**2 < @current
   end
     #Marks the spot at (x,y)
   def mark(x, y)
       if available?(x, y)
           @board[x][y] = @current
           @current += 1
       else
           raise "#{x},#{y} is not available"
       end
   end

   #Nice box output
   def to_s
       lines = "-" + "-"*5*@size + "\n"
       out = ""
       out << lines
       @board.each do |row|
           out << "|" << row.map { |num| num.to_s.rjust(4) }.join(' ') << "|\n"
       end
       out << lines
   end
end

raise "Please supply size" if ARGV[0].nil?

size = ARGV[0].to_i
raise "Size must be greater than 4" if size < 5

success = false

until success
   board = Board.new(size)
     #Pick random starting point
   x = rand(size)
   y = rand(size)
     #Mark the board there
   board.mark(x,y)
   success = true
     #Fill the board
   until board.full?
       avail = board.available_from(x, y).sort { rand }
             #No moves available
       if avail.empty?
           puts "Cannot proceed"
           success = false
           break
       end

       #Pick the best available move
       best = avail.inject { |best, pair|
           board.available_from(*pair).length < board.available_from(*best).length ? pair : best
       }

       #Mark the board
       x, y = best
       board.mark(x, y)
   end
end

#Output the solution
puts board
