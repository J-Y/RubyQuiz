#
# Maze builder and solver
#
# A response to Ruby Quiz #31 - Amazing Mazes [ruby-talk:141402]
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 10 May 2005
# Last Updated: 12 May 2005
#


class Cell
	def initialize(arg = false)
		@entrance = arg == '<'
		@goal = arg == '>'
		@footsteps = arg.to_i rescue 0
		@walkable = !['#', false, nil].include?(arg)
		@neighbours = {}
	end
	def to_s
		if @goal
			'>'
		elsif @entrance
			'<'
		elsif @walkable and @footsteps == 0
				' '
		elsif @walkable
			(@footsteps % 10).to_s
		else
			'#'
		end
	end
	def inspect
		"Cell(#{to_s})"
	end
	def neighbours2
		neighbours.inject({}) do |h, (dir, cell)|
			if cell.neighbours[dir]
				h[dir] = [cell, cell.neighbours[dir]]
			end
			h
		end
	end
	def walkable_neighbours
		neighbours.find_all {|dir, cell| cell.walkable? }.to_hash
	end
	def walkable_neighbours2
		neighbours2.find_all {|dir, (cell1, cell2)| cell2.walkable? }.to_hash
	end
	def unwalkable_neighbours2
		neighbours2.find_all {|dir, (cell1, cell2)| not cell2.walkable? }.to_hash
	end
	attr_accessor :walkable, :entrance, :goal, :footsteps, :neighbours
	def walkable?() @walkable end
	def walk!()     @footsteps += 1 end
	def clear!()    @footsteps = 0 end
	def entrance?() @entrance end
	def goal?()     @goal end
end

class Point
	def initialize(x = 0, y = 0)
		@x, @y = x, y
	end
	attr_accessor :x, :y
	def ==(other)
		@x == other.x and @y == other.y
	end
	def eql?(other)
		self == other
	end
	def hash
		@x.hash ^ @y.hash
	end
	def +(other)
		Point.new(@x + other.x, @y + other.y)
	end
	def -(other)
		Point.new(@x - other.x, @y - other.y)
	end
	def *(int)
		Point.new(@x * int, @y * int)
	end
	def /(int)
		Point.new(@x / int, @y / int)
	end
	def rotated(direction)
		case direction
		when :forward
			self.dup
		when :back, :reverse
			Point.new(-@x, -@y)
		when :right, :clockwise, :cw
			Point.new(-@y, @x)
		when :left, :counterclockwise, :ccw
			Point.new(@y, -@x)
		else
			raise ArgumentError.new("unrecognized rotation direction #{direction.inspect}")
		end
	end
	def inspect
		"Point(#@x, #@y)"
	end
	def to_s
		"(#@x, #@y)"
	end
	O = Point.new(0, 0)
	N = Point.new(0, -1)
	S = Point.new(0, 1)
	E = Point.new(1, 0)
	W = Point.new(-1, 0)
end

module Enumerable
	def to_hash
		h = {}
		each do |key, value|
			h[key] = value
		end
		h
	end
	def random
		to_a[rand(self.size)]
	end
	def shuffle
		sort_by {rand}
	end
	def shuffle!
		sort! {rand(3) - 1}
	end
end

require 'delegate'
class Maze < DelegateClass(Array)
	def initialize(algorithm, width, height)
		@width, @height = width, height
		__setobj__ Array.new(width) { Array.new(height) { Cell.new } }
		algorithm.call(self)
	end
	
	def solve(algorithm, *args)
		algorithm.call(self, *args)
	end

	attr_reader :width, :height
	def cells
		flatten
	end
	def walkable_cells
		cells.select {|c| c.walkable? }
	end
	def principal_cells
		unless @principal_cells
			@principal_cells = []
			1.step(width - 2, 2) do |x|
				1.step(height - 2, 2) do |y|
					@principal_cells << self[x][y]
				end
			end
		end
		@principal_cells
	end
	def entrance
		@entrance or @entrance = cells.find {|c| c.entrance? }
		
	end
	def goal
		@goal or @goal = cells.find {|c| c.goal? }
	end
	
	def set_goal!
		unless @goal
			@goal = principal_cells.random
			@goal.goal = true
			@goal
		end
	end
	
	def to_s
		transpose.map {|row| row.join }.join("\n")
	end
	
	#
	# Maze::Builders build paths and walls into the given Maze
	#
	module Builder
		LINK_CELLS = proc do |maze|
			h, w = maze.height, maze.width
			1.upto(w - 3) do |x|
				1.upto(h - 3) do |y|
					maze[x][y].neighbours[Point::E] = maze[x + 1][y]
					maze[x + 1][y].neighbours[Point::W] = maze[x][y]
					maze[x][y].neighbours[Point::S] = maze[x][y + 1]
					maze[x][y + 1].neighbours[Point::N] = maze[x][y]
				end
				maze[x][h - 2].neighbours[Point::E] = maze[x + 1][h - 2]
				maze[x + 1][h - 2].neighbours[Point::W] = maze[x][h - 2]
			end
			1.upto(h - 3) do |y|
				maze[w - 2][y].neighbours[Point::S] = maze[w - 2][y + 1]
				maze[w - 2][y + 1].neighbours[Point::N] = maze[w - 2][y]
			end
			maze.set_goal!
			maze
		end
		
		RECURSIVE_BACKTRACKER = proc do |maze|
			LINK_CELLS[maze]
			stack = []
			stack.push maze.principal_cells.random
			stack[-1].walkable = true
			stack[-1].entrance = true
			begin
				until (opts = stack[-1].unwalkable_neighbours2 ).empty?
					opts.random.last.each do |c|
						stack.push c
						c.walkable = true
					end
				end
				stack.pop
				stack.pop
			end until stack.empty?
			maze.set_goal!
			maze
		end
		
		PRIMS_ALGORITHM = proc do |maze|
			LINK_CELLS[maze]
			frontier = []
			cell = maze.principal_cells.random
			cell.walkable = true
			cell.entrance = true
			frontier |= cell.unwalkable_neighbours2.map {|p, (c1, c2)| c2 }
			until frontier.empty?
				cell = frontier.delete_at(rand(frontier.size))
				cell.walkable_neighbours2.map{|p,(c1,c2)| c1 }.random.walkable =
					cell.walkable = true
				frontier |= cell.unwalkable_neighbours2.map {|p, (c1, c2)| c2 }
			end
			maze.set_goal!
			maze
		end
	end
	
	#
	# Solvers return an Array of paths from the entrance to the goal of the
	# given Maze. Each path is an Array of Cells.
	#
	class Solver
		WALL_FOLLOWER = proc do |maze, *args|
			path = [maze.entrance]
			turns = if args.include? :left
				[:left, :forward, :right, :back]
			elsif args.include? :right
				[:right, :forward, :left, :back]
			else
				raise ArgumentError.new('missing required parameter, :left or :right')
			end
			dir = [Point::N, Point::S, Point::E, Point::W].random
			until path[-1].goal? or
			      (path[-1].entrance? and path[-1].neighbours.select{|p,c|c.footsteps == 0}.empty?)
				turns.each do |turn|
					c = path[-1].neighbours[dir.rotated(turn)]
					if c && c.walkable?
						c.walk!
						dir = dir.rotated(turn)
						path << c
						yield c if block_given?
						break
					end
				end
			end
			[path]
		end
		
		RANDOM_MOUSE = proc do |maze, *args|
			path = [maze.entrance]
			directions = [Point::N, Point::S, Point::E, Point::W]
			until path[-1].goal?
				directions.shuffle!.each do |dir|
					c = path[-1].neighbours[dir]
					if c && c.walkable?
						c.walk!
						path << c
						yield c if block_given?
						break
					end
				end
			end
			[path]
		end
	end
end

if $0 == __FILE__
	m = Maze.new(Maze::Builder::RECURSIVE_BACKTRACKER, 79, 11)
	puts m.to_s
	sol = m.solve(Maze::Solver::WALL_FOLLOWER, :left)
	puts "Solved in #{sol[0].size} steps"
	
	m = Maze.new(Maze::Builder::PRIMS_ALGORITHM, 79, 11)
	puts m.to_s
	puts "Warning: this random mouse may never finish the maze."
	n = m.solve(Maze::Solver::RANDOM_MOUSE, :left)
	puts "Solved in #{sol[0].size} steps"
end
