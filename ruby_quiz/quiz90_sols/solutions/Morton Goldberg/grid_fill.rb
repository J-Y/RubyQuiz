#! /usr/bin/ruby -w
# Author: Morton Goldberg
#
# Date: August 15, 2006
#
# Ruby Quiz #90 -- Pen and Paper Game

# A grid is a matrix of cells.
class Grid

   def initialize(dims)
      @rows, @cols = dims
      @size = @rows * @cols
      @grid = Array.new(@rows) {|i| Array.new(@cols) {|j| Cell.new(i, j)}}
   end

   # Return a deep copy.
   def copy
      result = Grid.new(dimensions)
      result.grid.each_with_index do |row, i|
         row.each_with_index {|cell, j| cell.val = self[i, j].val}
      end
      result
   end

   # Shifts the values of the cells in the grid by <offset> under the
   # constraint that values are folded into the range 1..@size.
   def shift!(offset)
      @grid.each do |row|
         row.each do |cell|
            val = (cell.val + offset) % @size
            cell.val = (val == 0 ? @size : val)
         end
      end
      self
   end

   # Return the dimensions of the grid.
   def dimensions
      [@rows, @cols]
   end

   # Return the cell at positon [row, col].
   # Call as <grid-name>[row, col]
   def [](*args)
      row, col = args
      @grid[row][col]
   end

   # Assigns a cell to the positon [row, col].
   # Call as <grid-name>[row, col] = cell
   def []=(*args)
      row, col, cell = args
      @grid[row][col] = cell
   end

   # Format the grid as a bordered table.
   def to_s
      rule = '-' * (4 * @cols + 4) + "\n"
      grid_str = ""
      @grid.each do |row|
         grid_str << row.inject("|  ") do |row_str, cell|
            row_str << ("%2d  " % cell.val)
         end
         grid_str << "|\n"
      end
      "" << rule << grid_str << rule
   end

   attr_reader :rows, :cols, :size, :grid

end

# A path is an array of cells, where no two cells occupy the same location
# in some grid. A complete path fills the grid.
class Path < Array

   # Make a deep copy of a path.
   def copy
      result = Path.new
      each {|cell| result << cell.dup}
      result
   end

  # Sequentially number the cells in the path.
   def number!
      each_with_index {|cell, i| cell.val = i + 1}
      self
   end

   # Report whether or not a path is cyclic.
   def cyclic?
      p0, p1 = self[0], self[-1]
      delta = [(p1.row - p0.row).abs, (p1.col - p0.col).abs]
      delta == [3, 0] || delta == [0, 3] || delta == [2, 2]
   end

   # Make a grid from a path.
   # Warning: if the path isn't complete, the resulting grid wont't
   # represent a solution.
   def to_grid(size)
      result = Grid.new([size, size])
      each {|cell| result[cell.row, cell.col] = cell}
      result
   end

end

# A cell is a simple object that knows its value and its position in
# a grid. It also encodes the game's movement rule.
class Cell

   def initialize(row, col, val=0)
      @row, @col = row, col
      @val = val
   end

   # Return a list of targets -- an array containing all the cells in the
   # grid reachable from this cell in one step.
   def targets(grid)
      size = grid.rows
      result = []
      result << grid[@row, @col - 3] if @col - 3 >= 0    # north
      result << grid[@row + 2, @col - 2] \
         if @row + 2 < size && @col - 2 >= 0             # northeast
      result << grid[@row + 3, @col] if @row + 3 < size  # east
      result << grid[@row + 2, @col + 2] \
         if @row + 2 < size && @col + 2 < size           # southeast
      result << grid[@row, @col + 3] if @col + 3 < size  # south
      result << grid[@row - 2, @col + 2] \
         if @row - 2 >= 0 && @col + 2 < size             # southwest
      result << grid[@row - 3, @col] if @row - 3 >= 0    # west
      result << grid[@row - 2, @col - 2] \
         if @row - 2 >= 0 && @col - 2 >= 0               # northwest
      result
   end

   attr_accessor :row, :col, :val

end

# A solver uses a depth-first search to find one solution for a square grid # of a given size.
class Solver

   def initialize(size)
      @size = size
      @solution = nil
      @test_grid = Grid.new([@size, @size])
      cell = @test_grid[0, 0]
      targets = cell.targets(@test_grid)
      goals = targets.dup
      @backtrack_chain = [[Path.new << cell, targets, goals]]
   end

   # Return a new link for the backtrack chain if it can be extended;
   # otherwise, return nil.
   def next_link
      path, targets, goals = @backtrack_chain.last
      return nil if targets.empty? || goals.empty?
      # Here is where the randomization takes place.
      cell = targets[rand(targets.size)]
      next_path = path.dup << cell
      # Restricts target list to accessible cells not already on the path.
      next_targets = cell.targets(@test_grid) - path
      next_goals = goals.dup
      next_goals.delete(cell) if goals.include?(cell)
      # Make sure cell won't be picked again if backtrack occurs.
      targets.delete(cell)
      [next_path, next_targets, next_goals]
   end

   # The algorithm is a randomized depth-first search.
   def solve
      final_size = @size * @size
      loop do
         link = next_link
         if link then
            @backtrack_chain.push(link)
         else
            @solution = @backtrack_chain.pop.first
            break if @solution.size == final_size
            if @backtrack_chain.empty? then
               raise(RuntimeError, "No solution for #@size x #@size grid")
            end
         end
      end
      @solution.number!
   end

   attr_reader :solution

end

SIZE = 5
solver = Solver.new(SIZE)
puts solver.solve.to_grid(SIZE)
