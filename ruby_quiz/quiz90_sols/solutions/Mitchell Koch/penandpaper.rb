#!/usr/bin/env ruby
# Pen and Paper

class PenAndPaper
	MOVES = {
		:n  => Proc.new { |x,y| [x,y-3] },
		:ne => Proc.new { |x,y| [x+2,y-2] },
		:e  => Proc.new { |x,y| [x+3,y] },
		:se => Proc.new { |x,y| [x+2,y+2] },
		:s  => Proc.new { |x,y| [x,y+3] },
		:sw => Proc.new { |x,y| [x-2,y+2] },
		:w  => Proc.new { |x,y| [x-3,y] },
		:nw => Proc.new { |x,y| [x-2,y-2] }
	}

	def initialize(n)
		@n = n
	end
	
	def solve(method=:lookfill)
		begin
			$stderr.print '.'
			@board = Board.new(@n)
			@count = 1
			send(method)
		end until @board.complete?
		$stderr.puts
		@board
	end

	def randfill
		move(rand(@n),rand(@n))
		until valid_moves.empty?
			dir = valid_moves.sort_by{rand}.first
			move(*new_pos(@pos, dir))
		end		
	end
	
	def lookfill
		move(@n/2, @n/2)
		until valid_moves.empty?
			dir = valid_moves.sort_by{rand}.sort do |a,b| 
				valid_moves(new_pos(@pos,a)).size <=> 
				valid_moves(new_pos(@pos,b)).size
			end.first
			move(*new_pos(@pos, dir))
		end		
	end

	def move(x,y)
		@pos = [x,y]
		@board[x,y] = @count
		@count += 1
	end
	
	def valid_moves(start=@pos)
		MOVES.keys.select {|d| valid_pos(*new_pos(start,d))}
	end

	def valid_pos(x,y)
		0 <= x && x < @n && 0 <= y && y < @n && @board[x,y] == '.'
	end
	
	def new_pos(start, dir)
		MOVES[dir].call(*start)
	end
end

class Board
	def initialize(x, y=x)
		@x, @y = x, y
		@arr = (1..y).inject([]) { |m,n| m << ['.']*x }
	end
	
	def []=(x, y, val)
		@arr[y][x] = val
	end
	
	def [](x, y)
		@arr[y][x]
	end
	
	def complete?
		@arr.each do |row|
			row.each do |space|
				return false if space == '.'
			end
		end
		true
	end
	
	def to_s
		numdigits = 1
		@arr.each do |row|
			row.each do |num|
				digits = num.to_s.size
				numdigits = digits if digits > numdigits
			end
		end
		s = ''
	  bookend = '+' + '-'*((numdigits+1)*@x+1) + "+\n"
		s << bookend
		@y.times do |y|
			s << '|'
			s << @arr[y].inject('') { |m,n| m << " %#{numdigits}s"%n }
			s << " |\n"
		end
		s << bookend
	end
end

if __FILE__ == $0
	n = ARGV[0] ? ARGV[0].to_i : 5
	puts PenAndPaper.new(n).solve
end
