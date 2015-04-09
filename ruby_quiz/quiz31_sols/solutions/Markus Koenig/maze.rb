#!/usr/bin/env ruby

# This is an ugly hack to redeem us from checking indices all the time
def nil.[](i)
	nil
end

# Visit encapsulates a selection of fields
class Visit < Array
	attr_accessor :turns

	def initialize
		@included = {}
	end

	def [](x, y)
		@included[y][x]
	end

	def add(x, y)
		if (@included[y] ||= {})[x]
			false
		else
			self << [x, y]
			@included[y][x] = true
		end
	end

	# from Latin "pons", bridge
	# select a random bridge
	def pons(other)
		xarr = []
		yarr = []
		dirarr = []
		each do |x, y|
			if other[x - 1, y]
				xarr << x
				yarr << y
				dirarr << :left
			end
			if other[x, y - 1]
				xarr << x
				yarr << y
				dirarr << :up
			end
			if other[x + 1, y]
				xarr << x
				yarr << y
				dirarr << :right
			end
			if other[x, y + 1]
				xarr << x
				yarr << y
				dirarr << :down
			end
		end
		# yield a bridge if there is at least one
		if dirarr.empty?
			return false
		else
			i = rand(dirarr.length)
			yield xarr[i], yarr[i], dirarr[i]
			return true
		end
	end
end

# Obviously encapsulates a maze
class Maze
	attr_reader :width, :height
	attr_accessor :selection

	def initialize(width, height)
		# initialize instance variables
		@width = width
		@height = height
		@go_right = Array.new(height) {Array.new(width, false)}
		@go_down = Array.new(height) {Array.new(width, false)}

		# generate the maze
		combs = combinations.sort_by{rand}
		until combs.empty?
			cur_comb = combs.shift
			unless add_path(*cur_comb)
				combs.push cur_comb
			end
		end
	end

	def add_path(x0, y0, x1, y1)
		neigh0 = neighbors(x0, y0)
		# return true if one can go from x0|y0 to x1|y1
		if neigh0[x1, y1]
			true
		else
			# remove the wall if we can
			neigh0.pons(neighbors(x1, y1)) do |x, y, dir|
				case dir
				when :left
					@go_right[y][x - 1] = true
				when :up
					@go_down[y - 1][x] = true
				when :right
					@go_right[y][x] = true
				when :down
					@go_down[y][x] = true
				end
			end
		end
	end

	def combinations
		max_index = @width * @height - 1
		arr = []

		max_index.times do |i0|
			x0 = i0 % @width
			y0 = i0 / @width
			(i0+1).upto(max_index) do |i1|
				x1 = i1 % @width
				y1 = i1 / @width
				arr << [x0, y0, x1, y1]
			end
		end

		return arr
	end

	def display
		curses = MazeCurses.new(5 * @width + 1, 3 * @height + 1)

		# draw the stipples
		if @selection
			@selection.each do |x, y|
				curses.stipple 5 * x, 3 * y, 6, 4
			end
		end

		# draw the outer border
		curses.box

		# draw the inner borders
		@height.times do |y|
			@width.times do |x|
				unless @go_right[y][x]
					curses.mvvline 5 * (x + 1), 3 * y, 4
				end
				unless @go_down[y][x]
					curses.mvhline 5 * x, 3 * (y + 1), 6
				end
			end
		end

		# throw the thing at stdout
		curses.wnoutrefresh
	end

	def go(x, y, direction)
		# try to go into a direction
		case direction
		when :left
			yield x - 1, y if @go_right[y][x - 1]
		when :up
			yield x, y - 1 if @go_down[y - 1][x]
		when :right
			yield x + 1, y if @go_right[y][x]
		when :down
			yield x, y + 1 if @go_down[y][x]
		end
	end

	def neighbors(x, y)
		neigh = Visit.new
		neigh.add x, y

		# add all neighbors
		done = false
		until done
			done = true
			neigh.each do |x, y|
				# try to go left
				if @go_right[y][x - 1] and neigh.add(x - 1, y)
					done = false
				end
				# try to go up
				if @go_down[y - 1][x] and neigh.add(x, y - 1)
					done = false
				end
				# try to go right
				if @go_right[y][x] and neigh.add(x + 1, y)
					done = false
				end
				# try to go down
				if @go_down[y][x] and neigh.add(x, y + 1)
					done = false
				end
			end
		end

		# the neighborhood is complete
		return neigh
	end

	def path(x0, y0, x1, y1, curdir = nil)
		# find a way from x0|y0 to x1|y1
		# this uses depth-first search

		if x0 == x1 and y0 == y1
			way = Visit.new
			way.add x0, y0
			way.turns = 0
			return way
		end

		case curdir
		when :left
			directions = [:left, :up, :down]
		when :up
			directions = [:left, :up, :right]
		when :right
			directions = [:up, :right, :down]
		when :down
			directions = [:left, :right, :down]
		else
			directions = [:left, :up, :right, :down]
		end

		directions.each do |direction|
			go x0, y0, direction do |x2, y2|
				way = path(x2, y2, x1, y1, direction)
				if way
					way.add x0, y0
					unless direction == curdir
						way.turns += 1
					end
					return way
				end
			end
		end

		return nil
	end
end

# A way to draw fancy or sludgy ASCII graphics
class MazeCurses
	# This has *nothing* to do with the curses library!

	def initialize(width, height)
		@width = width
		@height = height
		@matrix = Array.new(height) {' ' * width}
	end

	def box
		# draw a box around the edges of the matrix
		mvhline 0, 0, @width
		mvhline 0, @height-1, @width
		mvvline 0, 0, @height
		mvvline @width-1, 0, @height
	end

	def mvaddch(x, y, ch)
		case ch
		when ?-
			if @matrix[y][x] == ?|
				@matrix[y][x] = ?+
			elsif @matrix[y][x] != ?+
				@matrix[y][x] = ?-
			end
		when ?|
			if @matrix[y][x] == ?-
				@matrix[y][x] = ?+
			elsif @matrix[y][x] != ?+
				@matrix[y][x] = ?|
			end
		else
			@matrix[y][x] = ch
		end
	end

	def mvhline(x, y, n)
		n.times do |i|
			mvaddch x + i, y, ?-
		end
	end

	def mvvline(x, y, n)
		n.times do |i|
			mvaddch x, y + i, ?|
		end
	end

	def stipple(left, top, width, height)
		top.upto(top+height-1) do |y|
			left.upto(left+width-1) do |x|
				@matrix[y][x] = ?:
			end
		end
	end

	def wnoutrefresh
		puts @matrix
		puts
	end
end


if ARGV.length != 2
	puts 'usage: ruby maze.rb {height} {width}'
	exit
end

maze = Maze.new(ARGV[1].to_i, ARGV[0].to_i)
all_paths = maze.combinations.map{|x| maze.path(*x)}

puts "== Upper left to lower right =="
maze.selection = maze.path(0, 0, maze.width - 1, maze.height - 1)
maze.display

puts "== Longest path =="
maze.selection = all_paths.sort_by{|x| x.length}.last
maze.display

puts "== Most complicated path =="
maze.selection = all_paths.sort_by{|x| x.turns}.last
maze.display
