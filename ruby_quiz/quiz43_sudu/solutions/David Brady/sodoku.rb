#!/usr/bin/env ruby

# sodoku.rb - Sodoku puzzle solver.  Ruby Quiz #43.

# +-------+-------+-------+
# | _ 6 _ | 1 _ 4 | _ 5 _ |
# | _ _ 8 | 3 _ 5 | 6 _ _ |
# | 2 _ _ | _ _ _ | _ _ 1 |
# +-------+-------+-------+
# | 8 _ _ | 4 _ 7 | _ _ 6 |
# | _ _ 6 | _ _ _ | 3 _ _ |
# | 7 _ _ | 9 _ 1 | _ _ 4 |
# +-------+-------+-------+
# | 5 _ _ | _ _ _ | _ _ 2 |
# | _ _ 7 | 2 _ 6 | 9 _ _ |
# | _ 4 _ | 5 _ 8 | _ 7 _ |
# +-------+-------+-------+

# dbrady 2005-08-23: How my solver works: I try to find the fastest
# path to the solution by considering all of the possible solutions
# for each unsolved cell in the puzzle and working on the smallest
# set.  For example, the top-left cell (0,0), in the sample above,
# only has two possible solutions: 3 and 9.  All other digits are
# already present elsewhere in row 0 or column 0.  If cells on the
# board have a single solution, 2 will be the shortest list.  Many
# cells on this board have 2 solutions, for arbitrariness we'll take
# the first one we found.  (Edit: cell (5,2) only has one solution.
# we'll conveniently ignore that for now.)
#
# Now I consider all the possible solutions for that board.  I create
# a new board object, set that cell to a possible value, and recurse
# into that board, asking it to solve itself.
#
# Sodoku#solution returns either a solved Sodoku object, or nil.  If
# the top-level Sodoku board object returns nil, the puzzle is
# unsolvable.

# ----------------------------------------------------------------------
# A Note on Array Subtraction
# ----------------------------------------------------------------------
# This is published in the documentation for Array, but nobody ever
# reads that stuff (that's why nobody ever writes any).  I discovered
# this by fiddling with it in irb.  Array#- performs a difference
# operation.  Every element in the lhs that appears in the rhs is
# removed.
#
# [2,3,4,5] - [4,5,6] => [2,3]
# [2,3,3,3,3,4] - [3] => [2,4]  # EVERY element!
#
# I use this differencing op to obtain array intersection thusly:
#
# intersection = a - (a-b)
#
# You can immediately see how this is useful, given the nature of the
# puzzle.
#
# Anyway, if you see foo - [0], that's me clearing out all the
# unsolved cells from a list of cells.


# ======================================================================
# class Sodoku - 
# ======================================================================
# class Sodoku - representation of a Sodoku puzzle.  A Sodoku puzzle
# is a 9x9 grid, each containing numbers 1-9 such that every column
# and every row contains the complete set (1..9).  Stated conversely,
# no column or row contains the same number twice.
#
# Given a partially completed Sodoku puzzle, the class can find a
# solution if any exists.
#
# A Sodoku puzzle displays itself (using #to_s) akin to this sample:
#
# +-------+-------+-------+
# | _ 6 _ | 1 _ 4 | _ 5 _ |
# | _ _ 8 | 3 _ 5 | 6 _ _ |
# | 2 _ _ | _ _ _ | _ _ 1 |
# +-------+-------+-------+
# | 8 _ _ | 4 _ 7 | _ _ 6 |
# | _ _ 6 | _ _ _ | 3 _ _ |
# | 7 _ _ | 9 _ 1 | _ _ 4 |
# +-------+-------+-------+
# | 5 _ _ | _ _ _ | _ _ 2 |
# | _ _ 7 | 2 _ 6 | 9 _ _ |
# | _ 4 _ | 5 _ 8 | _ 7 _ |
# +-------+-------+-------+
#
# The board rows and columns are numbered 0-8.
class Sodoku
  attr_accessor :board

  # initialize - ctor.  Takes 1 arg, which is either a string
  # containing the representation of the puzzle, or another Sodoku
  # object, in which case we make a copy of its @board member.
  def initialize(str = nil)
    @board = []
    9.times do |y|
      @board[y] = [0,0,0,0,0,0,0,0,0]
    end
    self.load(str) if str.class == String
    if str.respond_to? :board
      self.copy_board(str)
    end
  end

  # returns true if this board has no duplicates in any row or column.
  def valid?
    valid = true
    return false unless @board.length == 9
    @board.each do |row|
      return false unless row.length == 9
      row.each do |cell|
        return false unless cell.class == Fixnum && cell<=9 && cell>=0
      end
      return false unless (row - [0]).uniq.length == (row - [0]).length
    end
    @board.transpose.each do |row|
      return false unless (row - [0]).uniq.length == (row - [0]).length
    end
    3.times do |by|
      3.times do |bx|
        block = []
        3.times do |y|
          3.times do |x|
            block.push @board[by*3+y][bx*3+x]
          end
        end
        return false unless (block - [0]).uniq.length == (block - [0]).length
      end
    end
    true
  end

  # returns true if any cell of this board has no solutions.
  def unsolvable?
    9.times do |y|
      9.times do |x|
        next unless @board[y][x].zero?
        return true if self.possible_values(x,y).nil?
      end
    end      
    false
  end

  # find_pinch - returns an array of two Fixnums containing the (x,y)
  # of the unsolved cell with the fewest possible solutions.  If
  # multiple cells tie for shortest solution, only one is returned.
  # If board is solved, returns nil.
  def find_pinch
    pinch = nil
    pinch_xy = nil
    9.times do |y|
      9.times do |x|
        next unless @board[y][x].zero?
        values = self.possible_values(x,y)
        if pinch.nil? || pinch.length > values.length
          pinch = values
          pinch_xy = [x,y]
        end
      end
    end
    pinch_xy
  end

  # returns array of possible values at (x,y).  If the cell is solved,
  # the array will contain only the one element.
  def possible_values(x,y)
    pv = self.possible_row_values(y) - (self.possible_row_values(y) - self.possible_col_values(x))
    pv -= (pv - self.possible_block_values(x,y))
    return nil if pv.length.zero?
    pv
  end

  # returns array of still-available values for this row.  If the row
  # is solved, returns empty array
  def possible_row_values(y)
    [1,2,3,4,5,6,7,8,9] - @board[y]
  end

  # returns array of still-available values for this col.  If the col
  # is solved, returns empty array
  def possible_col_values(x)
    vv = [1,2,3,4,5,6,7,8,9]
    9.times do |row|
      vv -= [@board[row][x]]
    end
    vv
  end

  # returns array of still-available values for the block that
  # contains this cell.  If the block is solved, returns empty array.
  def possible_block_values(x,y)
    vv = [1,2,3,4,5,6,7,8,9]
    block_x = x/3
    block_y = y/3
    3.times do |y|
      3.times do |x|
        vv -= [@board[y+block_y*3][x+block_x*3]]
      end
    end
    vv
  end
  
  # sets the value of cell (x,y) to val.
  def set(x,y,val)
    @board[y][x] = val
  end

  # Loads the @board array from a string matching the example above.
  def load(str)
    line_num = 0
    str.each_line do |line|
      line.delete!('+|-')
      line.gsub!('_','0')
      line.strip!
      if line.length > 0
        l = line.split /\s+/
        fail "Line length was #{l.length}.  line: #{line}" unless l.length == 9
        @board[line_num] = l.collect {|x| x.to_i}
        line_num += 1
      end
    end

    fail "Board is not valid." unless self.valid?
  end

  # Returns the board as a string.
  def to_s
    s = ''
    bar = "+-------+-------+-------+\n"
    s += bar
    9.times do |y|
      s += sprintf("| %d %d %d | %d %d %d | %d %d %d |\n",
                   @board[y][0], @board[y][1], @board[y][2],
                   @board[y][3], @board[y][4], @board[y][5],
                   @board[y][6], @board[y][7], @board[y][8], @board[y][9] );
      s += bar if y % 3 == 2
    end
    s.gsub! '0', '_'
    s
  end

  # Returns true if board is solved.
  def solved?
    # trivially reject us if we're invalid.
    return false unless self.valid?

    # every row must contain (1..9)
    @board.each do |row|
      return false unless row.sort == [1,2,3,4,5,6,7,8,9]
    end
    # every col must contain (1..9)
    @board.transpose.each do |col|
      return false unless col.sort == [1,2,3,4,5,6,7,8,9]
    end
    # every block must containt (1..9)
    3.times do |by|
      3.times do |bx|
        block = []
        3.times do |y|
          3.times do |x|
            block.push @board[by*3+y][bx*3+x]
          end
        end
        return false unless block.sort == [1,2,3,4,5,6,7,8,9]
      end
    end
  end

  # When you choose a trial value for a cell, sometimes other cells
  # will end up with only a single solution.  settle solves those
  # cells.  Settling a cell may cause other cells to become
  # settleable, so settle repeats until the board "settles"
  # completely.
  #
  # If all but one cell in a block are now settled, we could settle
  # that block, but testing for this is too expensive.
  def settle
    settled = false
    until settled
      settled = true
      9.times do |y|
        9.times do |x|
          if @board[y][x].zero?
            pv = self.possible_values(x,y)
            if !pv.nil? && pv.length == 1
              # danger - if pv.nil?, we have invalidated the board.
              # This may well be possible.
              settled = false
              self.set(x,y,pv[0])
            end
          end
        end
      end
    end
  end

  # Returns an array depiction of the integer contents of @board (used
  # primarily for debugging)
  def board_array
    s = ''
    @board.each do |row|
      s += " [" + row.join(', ') + "],\n"
    end
    s = '[' + s[1..-3] + ']'
  end

  # Returns first found solution, or nil if board is not solvable.
  def solution
    return self if self.solved? 
    return nil if self.unsolvable?

    pinch = self.find_pinch
    return nil if pinch.nil?
    values = self.possible_values(pinch[0], pinch[1])
    
    values.each do |value|
      b = Sodoku.new
      b.copy_board(self)
      b.set(pinch[0], pinch[1], value)
      b.settle
      if b.valid? && b.solved?
        return b
      end

      # not solved; recurse.
      solution = b.solution
      if !solution.nil? && solution.valid?
        return solution
      end
    end
    nil
  end

  def copy_board(other)
    @board = []
    other.board.each do |row|
      @board.push( row.dup )
    end
  end
    
end

if $0 == __FILE__
  # Read in board from STDIN, attempt solve and display output.
  b = Sodoku.new(ARGF.readlines().join())
  puts b
  solution = b.solution
  if !solution.nil?
    puts "Solution:"
    puts solution
  else
    puts "*** This board has no solution."
  end
end
