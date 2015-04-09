#!/usr/bin/env ruby

def Array.make2d(h, w, value)
	# make a two-dimensional Array initialized with value
	line = [value] * w
	arr = Array.new
	h.times do
		arr.push line.dup
	end
	return arr
end

class Crossword
	# --instance vars--
	#   @h: height
	#   @w: width
	#   @board: square types (2d array)
	#      true: filled inner square
	#      false: non-filled inner square
	#      nil: previously filled outer square
	#   @numbers: square number (2d array)
	#      Integer: this number
	#      nil: no number

	# output options
	CBORDER = '#'
	CFREE = ' '

	def Crossword.parse
		# parse ARGF

		arr = [[]]
		y = 0
		until ARGF.eof
			case ARGF.getc
			when ?_, ?-
				arr[y].push false
			when ?X, ?x
				arr[y].push true
			when ?\n
				if arr[y].length != 0
					arr.push []
					y += 1
				end
			end
		end

		h = (arr[y].length == 0) ? y : y + 1
		w = arr.map{|subarr| subarr.length}.max

		cw = Crossword.new(h, w)
		h.times do |y|
			w.times do |x|
				cw.board[y][x] = true if arr[y][x] != false
			end
		end
		return cw
	end

	def initialize(h, w)
		@h = h
		@w = w
		@board = Array.make2d(h, w, false)
	end

	attr_reader :board

	def empty_filled_square(y, x)
		# recursively replace a filled area with nils

		return if y < 0 or x < 0
		return if y >= @h or x >= @w
		return if @board[y][x] != true
		@board[y][x] = nil
		empty_filled_square y-1, x
		empty_filled_square y+1, x
		empty_filled_square y, x-1
		empty_filled_square y, x+1
	end
	private :empty_filled_square

	def calculate_layout
		# calculate @numbers and empty outer filled squares

		@numbers = Array.make2d(@h, @w, nil)

		current = 1
		@h.times do |y|
			@w.times do |x|
				next if is_filled(y, x)
				if (is_filled(y-1, x) and not is_filled(y+1, x)) \
				or (is_filled(y, x-1) and not is_filled(y, x+1))
					@numbers[y][x] = current
					current += 1
				end
			end
		end

		@h.times do |y|
			empty_filled_square y, 0
			empty_filled_square y, @w - 1
		end
		@w.times do |x|
			empty_filled_square 0, x
			empty_filled_square @h - 1, x
		end
	end
	private :calculate_layout

	def is_filled(y, x)
		return true if y < 0 or x < 0 or y >= @h or x >= @w
		@board[y][x]
	end
	def has_hborder(y, x)
		if y == 0
			@board[0][x] != nil
		elsif y == @h
			@board[y-1][x] != nil
		else
			@board[y-1][x] != nil or @board[y][x] != nil
		end
	end
	def has_vborder(y, x)
		if x == 0
			@board[y][0] != nil
		elsif x == @w
			@board[y][x-1] != nil
		else
			@board[y][x-1] != nil or @board[y][x] != nil
		end
	end
	def has_node(y, x)
		return true if y != 0 and has_vborder(y-1, x)
		return true if x != 0 and has_hborder(y, x-1)
		return true if y != @h and has_vborder(y, x)
		return true if x != @w and has_hborder(y, x)
		return false
	end
	private :is_filled, :has_hborder, :has_vborder, :has_node

	def display
		calculate_layout

		print(has_node(0, 0) ? CBORDER : CFREE)
		@w.times do |x|
			print((has_hborder(0, x) ? CBORDER : CFREE) * 4)
			print(has_node(0, x+1) ? CBORDER : CFREE)
		end
		puts
		@h.times do |y|
			print(has_vborder(y, 0) ? CBORDER : CFREE)
			@w.times do |x|
				if is_filled(y, x)
					print CBORDER * 4
				elsif @numbers[y][x]
					nm = @numbers[y][x].to_s
					print nm
					print CFREE * (4 - nm.length)
				else
					print CFREE * 4
				end
				print(has_vborder(y, x+1) ? CBORDER : CFREE)
			end
			puts
			print(has_vborder(y, 0) ? CBORDER : CFREE)
			@w.times do |x|
				print((is_filled(y, x) ? CBORDER : CFREE) * 4)
				print(has_vborder(y, x+1) ? CBORDER : CFREE)
			end
			puts
			print(has_node(y+1, 0) ? CBORDER : CFREE)
			@w.times do |x|
				print((has_hborder(y+1, x) ? CBORDER : CFREE) * 4)
				print(has_node(y+1, x+1) ? CBORDER : CFREE)
			end
			puts
		end
	end
end


# this is the "main" program
cw = Crossword.parse
cw.display
