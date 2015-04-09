#!/usr/bin/env ruby

class Sudoku
	def initialize(boardstring)
		@board = Array.new(9)
		9.times { |i| @board[i] = Array.new(9) }
		flattened = boardstring.delete("-+|\n").split
		index = 0
		@unknown = []

		# set up actual array
		9.times do |i|
			9.times do |j|
				if(flattened[index] == '_') then
					@board[i][j] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
					@unknown << [i,j]
				else
					@board[i][j] = flattened[index].to_i
				end
				index += 1
			end
		end

		#set up what each row, col, and box contains
		@rows = Array.new(9)
		@cols = Array.new(9)
		@boxes = Array.new(9)
		9.times { |i| @rows[i] = numsInRow(i) }
		9.times { |j| @cols[j] = numsInCol(j) }
		3.times { |i| 3.times { |j| @boxes[i+3*j] = numsInBox(3*i,3*j) } }
	end

	def numsInRow(row)
		toreturn = []
		9.times do |j|
			if(@board[row][j].kind_of? Fixnum) then
				toreturn << @board[row][j]
			end
		end
		return toreturn
	end

	def numsInCol(col)
		toreturn = []
		9.times do |i|
			if(@board[i][col].kind_of? Fixnum) then
				toreturn << @board[i][col]
			end
		end
		return toreturn
	end

	def numsInBox(boxrow, boxcol)
		toreturn = []
		x = boxrow - boxrow%3
		y = boxcol - boxcol%3
		3.times do |i|
			3.times do |j|
				if(@board[x+i][y+j].kind_of? Fixnum) then
					toreturn << @board[x+i][y+j]
				end
			end
		end
		return toreturn
	end

	def to_s
		s = ""
		9.times do |i|
			if(i%3 == 0) then
				s += "+-------+-------+-------+\n"
			end
			9.times do |j|
				if(j%3 == 0) then
					s += "| "
				end
				if(@board[i][j].kind_of? Array) then
					s += "_ "
				else
					s += "#{@board[i][j]} "
				end
			end
			s += "|\n"
		end
		s += "+-------+-------+-------+\n"
		return s
	end

	# Looks in row, column and box to eliminate impossible values
	def eliminate(i,j)
		changed = false
		if(@board[i][j].kind_of? Array) then
			combined = @rows[i] | @cols[j] | @boxes[(i/3)+(j-j%3)]
			if( (@board[i][j] & combined).length > 0) then
				changed = true
				@board[i][j] -= combined
			end

			if(@board[i][j].length == 1) then
				foundsolution(i,j,@board[i][j][0])
			end
		end
		return changed
	end

	def foundsolution(x,y,val)
		@board[x][y] = val
		@rows[x] << @board[x][y]
		@cols[y] << @board[x][y]
		@boxes[(x/3)+(y-y%3)] << @board[x][y]
		@unknown.delete([x,y])
	end

	def eliminateall
		changed = true
		while(changed)
			changed = false
			@unknown.each do |u|
				if(eliminate(u[0],u[1])) then changed = true end
			end
		end
		return changed
	end

	#these check functions look for squares that have multiple
	# possibilities except the set itself only has one.
	def checkrow(i)
		changed = false
		set = Hash.new
		9.times do |j|
			if (@board[i][j].kind_of? Array) then
				@board[i][j].each do |e|
					if(set[e]) then
						set[e] << j
					else
						set[e] = [j]
					end
				end
			end
		end
		set.each do |k,v|
			if(v.length == 1) then
				foundsolution(i,v[0],k)
				changed = true
			end
		end
		return changed
	end

	def checkcol(j)
		changed = false
		set = Hash.new
		9.times do |i|
			if (@board[i][j].kind_of? Array) then
				@board[i][j].each do |e|
					if(set[e]) then
						set[e] << i
					else
						set[e] = [i]
					end
				end
			end
		end
		set.each do |k,v|
			if(v.length == 1) then
				foundsolution(v[0],j,k)
				changed = true
			end
		end
		return changed
	end

	def checkbox(n)
		x = 3*(n%3)
		y = 3*(n/3)
		changed = false
		set = Hash.new
		3.times do |i|
			3.times do |j|
				if (@board[x+i][y+j].kind_of? Array) then
					@board[x+i][y+j].each do |e|
						if(set[e]) then
							set[e] << [x+i,y+j]
						else
							set[e] = [ [x+i,y+j] ]
						end
					end
				end
			end
		end
		set.each do |k,v|
			if(v.length == 1) then
				foundsolution(v[0][0], v[0][1], k)
				changed = true
			end
		end
		return changed
	end

	def checkallrows
		changed = false
		9.times do |i|
			if(checkrow(i)) then changed = true end
		end
		return changed
	end

	def checkallcols
		changed = false
		9.times do |j|
			if(checkcol(j)) then changed = true end
		end
		return changed
	end

	def checkallboxes
		changed = false
		9.times do |n|
			if(checkbox(n)) then changed = true end
		end
		return changed
	end

	def solve
		#is there a better way to do this? it seems messy
		# and redundant.
		changed = true
		while(changed && @unknown.length>0)
			changed = false
			changed = eliminateall ? true : changed
			changed = checkallrows ? true : changed
			changed = eliminateall ? true : changed
			changed = checkallcols ? true : changed
			changed = eliminateall ? true : changed
			changed = checkallboxes ? true : changed
		end
		puts self
		if(@unknown.length>0)
			puts "I can't solve this one"
		end
	end
end

board = Sudoku.new($stdin.readlines.join)
board.solve
