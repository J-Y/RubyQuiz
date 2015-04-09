module RubyQuiz90
	class Board

		# Changes:
		#    pad row with 3 guard rows above and below
		#      this allows available? to avoid having to catch
		#      nil not understanding []
		def initialize(size)
			@row = Array.new(size+6)
		        (0..2).each { | i | @row[i] = Array.new(size) }
			(3..size+2).each { | i | @row[i] = Array.new(size, 0) }
			(size+3..size+5).each { | i | @row[i] = Array.new(size) }
			@size = size
#			@range = (0..size-1)
		end

		def take(row, col, value)
			@row[row+3][col] = value
		end

		def available?(row, col)
			@row[row+3][col] == 0 rescue false
		end

		def take_back(row, col)
			@row[row+3][col] = 0
		end

		def value(row, col)
			@row[row+3][col]
		end

		def to_s
			elem_width = ((@size * @size).to_s.length) + 1
			header = '+-' + ('-' *(@size * elem_width)) + '+'
			result = header.dup
			(0...@size).each do | i |
				row = @row[i+3]
				result << "\n|"
				row.each do | elem |
				           result << ((elem == 0) ?
						      (" " * elem_width) :
						      sprintf("%#{elem_width}d", elem))
				end
			result << ' |'
			end
			result << "\n"
			result << header
		end

		def self.testboard(s)
			b = new(s)
			(0..s-1).each do | r |
				(0..s-1).each do | c |
				b.take(r, c, c + 1 + (r*s))
				end
			end
			b
		end

	end

	class Player
		Direction_vectors = [
			[0, 3],   #move east
			[2, 2],   #move southeast
			[3, 0],   #move south
			[2, -2],  #move southwest
			[0, -3],  #move west
			[-2, -2], #move northwest
			[-3, -3], #move north
			[-2, 2],  #move northeast
		]

		#		No_more_moves = Direction_vectors.length
		#		
		#		Last_move = (No_more_moves) - 1

		def initialize(size, debug = 2)
			@board = RubyQuiz90::Board.new(size)
			@last = size * size
			@debug = debug
		end

		def play (start_row=nil, start_col=nil)
			row = start_row || rand(@board.size)
			col = start_col || rand(@board.size)
			@board.take(row, col, 1)
			fill_all_from(start_row, start_col)
		end

		def board
			@board
		end

		# Fill the board after the last number was placed at r,c
		# If the board can be filled return true
		# If the board cannot be filled restore the board to its
		# initial state at the time of this call and return false
		def fill_all_from(r, c)

			value = @board.value(r,c) + 1

			puts "Trying to fill board starting with #{value}, from #{r},
#{c}}" if @debug > 2
			puts @board if @debug >= 3
			return true if value > @last # our work is done!

			#now try to fill the next value
			optimized_moves(r, c).each do | move |
				row = move.row
			        col = move.col
				puts "Trying to move placing #{value} at #{row}, #{col}" if @debug > 2
				@board.take(row, col, value)
				puts "Placed #{value} at #{row}, #{col}" if @debug > 2
				if fill_all_from(row, col)
						return true
				else
					@board.take_back(row, col)
				end
			end

			# if we get here, it's time to back out
			puts "All trials failed at #{value}" if @debug > 2
			puts @board if @debug > 2
			return false
		end
               # return a list of moves from row, col optimized so that
		# squares with more possible further moves come first
		def optimized_moves(row, col)
			moves = []
			Direction_vectors.each do | dx, dy |
				r = row + dy
			        c = col + dx
				if @board.available?(r,c)
					moves << Move.new(r, c, availability_count(r, c))
				end
			end
			moves.sort!
			moves	
		end
		
               # return the number of available squares from row, col
		def availability_count(row, col)
			Direction_vectors.inject(0) do | sum, (dx, dy)|
			       	@board.available?(row+dy, col+dx) ? sum + 1 : sum
			end
		
		end
	end

	class Move
		attr_accessor :row, :col, :count
		def initialize(r, c, count)
			@row = r
			@col = c
			@count = count
		end

		# a move is greater (should come later) if it has a lower
		# available move count than another
		def <=>(move)
			count - move.count
		end

		def to_s
			"Count=#{@count}, row=#{@row}, col=#{@col}"
		end
	end	
		
end
