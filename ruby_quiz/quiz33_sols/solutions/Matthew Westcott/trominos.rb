#!/usr/bin/ruby

# Proof by induction
# Base case: a 2x2 board with one missing square.
#   Trivially, the remaining 3 squares form an L-tromino.
# Step:
#   Assume that any (2**(n-1) x 2**(n-1)) board with a square missing can be solved.
#   A (2**n x 2**n) board can be divided into four (2**(n-1) x 2**(n-1)) quadrants.
#   One of these quadrants contains the missing square.
#   An L-tromino can be placed in the centre of the board, rotated such that it occupies
#   one square of each of the other three quadrants.
#   The result of this is four quadrants, each of which has one square missing.
#   By our original assumption, each of these can be solved.

# Note that at each stage of subdivision, each quadrant contains precisely one
#   square that is either 1) the missing square, or 2) occupied by an L-tromino
#   that overlaps onto other quadrants.

class Square
	# Represents a square portion of the board.
	
	attr_reader :central_corner_x, :central_corner_y
	
	def initialize(size, left = 0, top = 0, central_corner_x = nil, central_corner_y = nil)
		@size = size # Size of this square
		@left = left # X coordinate of leftmost point
		@top = top # Y coordinate of topmost point
		@central_corner_x = central_corner_x
		@central_corner_y = central_corner_y
			# Coordinates of the corner closest to the middle
			# of the parent square (or nil if the square has no parent)
			
		if size > 1
			# divide into quadrants
			quad_size = @size / 2
			@quadrants = [
				Square.new(quad_size, @left, @top, @left + quad_size - 1, @top + quad_size - 1),
				Square.new(quad_size, @left + quad_size, @top, @left + quad_size, @top + quad_size - 1),
				Square.new(quad_size, @left, @top + quad_size, @left + quad_size - 1, @top + quad_size),
				Square.new(quad_size, @left + quad_size, @top + quad_size, @left + quad_size, @top + quad_size)
			]
		end
	end
	
	def contains?(x, y)
		# Determine whether this square contains the given point
		(@left...(@left+@size)) === x && (@top...(@top+@size)) === y
	end
	
	def solve(board, missing_x, missing_y, count = 1)
		# board = a board which is to have the portion indicated by this Square object filled with L-trominos
		# missing_x, missing_y - the coordinates of a square not to be filled
		# count = the current L-tromino number
		# Returns the next available unused L-tromino number
		if @size == 1
			board[@top][@left] = count unless contains?(missing_x, missing_y)
			count
		else
			next_count = count + 1
			@quadrants.each { |quadrant|
				if quadrant.contains?(missing_x, missing_y)
					# a square in this quadrant is already missing - can solve the quadrant straight off
					next_count = quadrant.solve(board, missing_x, missing_y, next_count)
				else
					# artificially 'create' a missing square before solving the quadrant
					board[quadrant.central_corner_y][quadrant.central_corner_x] = count
					next_count = quadrant.solve(board, quadrant.central_corner_x, quadrant.central_corner_y, next_count)
				end
			}
			next_count
		end
	end
end

puts "Board magnitude? (1 = 2x2, 2 = 4x4, 3 = 8x8, 4 = 16x16...)"
n = gets.to_i
size = 2**n
digits = (n*2) / 5 + 1 # how many base-32 digits we need to give each L-tromino its own ID

board = (0...size).collect{ (0...size).collect { 0 } }
Square.new(size).solve(board, rand(size), rand(size))

board.each do |row|
	puts row.map{ |i| i.to_s(32).rjust(digits) }.join(' ')
end
