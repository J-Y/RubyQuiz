#!/usr/bin/env ruby

=begin rdoc
The Ruby Sudoku Solver

Mohit Muthanna Cheppudira <mohit@muthanna.com>

Sudoku, Japanese,  sometimes spelled Su Doku, 
is a placement puzzle, also known as Number Place in the 
United States. The aim of the puzzle is to enter a numeral 
from 1 through 9 in each cell of a grid, most frequently a 
9×9 grid made up of 3×3 subgrids (called "regions"), starting 
with various numerals given in some cells (the "givens"). Each 
row, column and region must contain only one instance of each 
numeral.

To Learn more about Sudoku, visit the great Wikipedia.

This implementation of the Sudoku solver uses an educated brute
force approach. By educated brute-force, I mean the solver:

* Narrows down options available in the empty places
* Fills in cells that have only one option
* For cells that have more than one option:
  * Try each one, then recurse (Narrow down, fill-in, etc.).

This file consists of five classes:

* Line: Represents a set of 9 cells. This could be a Row, a
Column, or a Region.

* Options: Represents a set of valid options for a cell. This is 
meant to be used as a workspace or scratch-pad for the Solver.

* Board: Represents the 9x9 Sudoku board. Has helper methods
to access cells, rows, columns and regions.

* Csv: Utility class used to load boards from CSV files.

* Solver: Our educated brute-force solver. Quite cool.
=end

module Sudoku


=begin rdoc

A Sudoku Line is basically an array that is
1-indexed. A Line could be a complete row, column or region.

=end

class Line < Array

=begin rdoc
This class variable represents the set of digits that
are valid in a Sudoku cell.
=end

  @@valid_digits = [1, 2, 3, 4, 5, 6, 7, 8, 9] 

=begin rdoc
We overload the [] operator so that the cells are
indexed from 1 till 9, instead of 0 till 8.
=end

  def []( num )
    at( num - 1 )
  end

=begin rdoc
The to_s method is called by other methods that
need a string representation of the class. E.g., puts()
 
In this case, the code:

   line = Line.new << 0 << 1 << 4 << 5
   puts line
  
Displays:
  
  0, 1, 4, 5
=end

  def to_s
    self.join( ", " )
  end

=begin
This method returns a list of missing digits
in the line.
=end

  def missing_digits
    return @@valid_digits - self
  end

=begin
Check if the Line or Region is
valid, i.e., has unique digits between
1 and 9, and has no zeros.

This method is used by the Solver to determine
if the solution is correct.
=end

  def valid?
    digits = Array.new

    # Navigate each cell:
    (1..9).each do |value|

      # Invalid if any zeros.
      return false if self[value] == 0 

      # Invalid if duplicate.
      if digits[self[value]] == true 
        return false
      else 
        # First occurrence. Log it.
        digits[self[value]] = true
      end
    end

    # Valid Line.
    return true
  end
end

=begin rdoc
This class defines a basic 9 x 9 Sudoku
board. The board is subdivided into smaller
3 x 3 regions. These regions are numbered
from 1 to 9 as so: Top to Bottom, Left to Right.

e.g., Top Left is Region 1
      The region beneath 1 (row 4, col 1) is 2
      Top Middle is Region 4.

      You get the picture.
=end

class Board
  def initialize( board = nil )
    if board == nil
      reset
    else
      # Our copy constructor. In ruby all variables are
      # references to classes. Copies have to be 
      # explicit. 
      reset
      board.each {|row, col, val| self[row,col] = val}
    end
  end

=begin rdoc
Our board is represented by a two-dimensional 9x9 array.
=end

  def reset
    @board = Array.new( 9 ) { Array.new( 9, 0 ) }
  end

=begin rdoc
Cells in this board can be referenced with this method. Uses row, col; not x, y.
A bit retarded, but works.
=end

  def []( row, col )
    return @board[col-1][row-1]
  end

  def []=( row, col, val )
    return (@board[col-1][row-1] = val)
  end

=begin
Draw up a simple ASCII Sudoku board.
=end

  def to_s
    string = "    1  2  3  4  5  6  7  8  9\n"
    string += "  +--------------------------\n"
    filled_in = 0

    (1..9).each do |r| 
      row( r ).each { |cell| filled_in += 1 unless cell == 0 }
      string += r.to_s + " | " + row( r ).to_s + "\n"
    end

    return string + "Filled: #{filled_in} / 81\n"
  end

  def row( row_num )
    r = Line.new
    (1..9).each { |c| r << self[ row_num, c ] }

    return r
  end

  def col( col_num )
    return Line.new( @board[ col_num - 1] )
  end

=begin
Return a region (class Line) of cells determined
by a region number. The regions are numbered incrementally
top to bottom, left to right. So the cell at row 2, column
2 is at region 1; 5, 5 is region 5; 7, 4 is region 8.
=end
  def region( region_num )
    region = Line.new

    start_row = ((( (region_num - 1) % 3 )) * 3) + 1
    start_col = (((region_num - 1) / 3) * 3) + 1

    (start_row..start_row + 2).each do |row|
      (start_col..start_col + 2).each do |col|
        region << self[row, col]
      end
    end

    return region
  end

=begin
Return a region number given a row and column.
=end
  def get_region_num( row, col )
    region_row = ( (row - 1) / 3 ) + 1
    region_col = ( (col - 1) / 3 ) + 1

    region_num = region_row + ( 3 * (region_col - 1))
  end

=begin
Used to iterate through each cell on the board.
=end
  def each
    (1..9).each do |row|
      (1..9).each do |col|
        yield row, col, self[row, col]
      end
    end
  end

=begin rdoc
Go through each row, column and region to 
determine if the board is valid.
=end

  def valid?
    (1..9).each do |line|
      return false if (
        !row( line ).valid? ||
        !col( line ).valid? ||
        !region( line ).valid? 
        )
    end

    return true
  end

end

=begin
This class loads a Sudoku board from a CSV file, A sample
board would look like this:

# Sample Board

0,0,0,0,2,3,4,0,0
0,6,3,0,9,8,0,0,0
4,0,0,5,0,0,0,0,0
0,2,5,0,8,0,0,7,3
0,1,0,0,0,0,0,5,0
6,4,0,0,5,0,1,9,0
0,0,0,0,0,5,0,0,8
0,0,0,9,7,0,3,6,0
0,0,6,8,3,0,0,0,0

Blank lines and lines beginning with hashes (#) are
ignored.

You can also save to CSV files by generating a 
string via the to_s method.
=end

class Csv
  def initialize( board = nil )
    if board == nil
      @board = Board.new
    else
      @board = board
    end
  end

  def load( file_name )
    File.open( file_name, "r" ) do |file|
      row = 1

      while line = file.gets

        # Strip out all comments and
        # blank lines.
        line.chomp!
        next if line =~ /^\s*#/
        next if line =~ /^\s*$/

        col = 1
        line.split(",").each do |value|
          @board[row, col] = value.to_i
          col += 1
        end

        row += 1
      end
    end

    @board
  end

=begin rdoc
Generate a CSV string representing the board.
=end
  def to_s
    string = ""

    (1..9).each do |r| 
      string += @board.row( r ).to_s + "\n"
    end

    return string 
  end
end

=begin
This class is represents a set of options for Sudoku cells. It's
simply a three dimensional array.
=end

class Options
  def initialize
    @options = Array.new( 9 ) { Array.new( 9 ) { Array.new } }
  end

  def []( row, col )
    return @options[col-1][row-1]
  end
  
  def []=( row, col, val )
    return (@options[col-1][row-1] = val)
  end

  def to_s
    string = ""

    (1..9).each do |row|
      (1..9).each do |col|
        string += self[row, col].join(",") + ":"
      end
      string += "\n"
    end

    string
  end 
end

=begin
Our Edumicated Brute-Force Sudoku Solver.
=end

class Solver
  
  attr_accessor :board, :options

  def initialize( board=nil )
    if board
      @board = board
    else 
      @board = Board.new
    end    
    
    @options = Options.new
  end

=begin rdoc
This method returns a list of digits that are valid inside
a specific cell. It works by subtracting the set of cells
in the specific row, column and region from a full-line, i.e,
[1, 2, 3, 4, 5, 6, 7, 8, 9].
=end

  def calculate_options_at( row, col )
    ( 
      [1, 2, 3, 4, 5, 6, 7, 8, 9] -
      board.row( row ) - 
      board.col( col ) - 
      board.region( 
        board.get_region_num( row, col ) 
      )
    )
  end

=begin rdoc
This method navigates through each cell in the board,
calculating a set of options for the cell. For cells
that have just one available option:

  * Set the cell with the available option.
  * Recalculate options.

If no options could be calculated, we hit a dead-end; return
false.
=end

  def calculate_options
    again = true
    have_options = false

    while again
      again = false
      self.options = Options.new

      # Navigate each cell...
      board.each do |row, col, value|

        # If the cell is empty...
        if value == 0
          
          # Set the options for the cell
          options[ row, col ] += calculate_options_at( row, col )
        end

        # How many options do we have?
        number_of_options = options[row, col].length

        # We had atleast one option; set return code.
        have_options = true if number_of_options > 0

        # Only one option here, reflect it on the
        # board.
        if number_of_options == 1
          board[row, col] = options[row, col][0]
          again = true
        end
      end
    end

    have_options
  end

=begin rdoc
Our solve algorithm. 
=end
  def brute_force

    # First narrow the board down.
    calculate_options

    # Navigate each cell
    board.each do |row, col, value|

      # If we see and empty cell:
      if value == 0

        # Navigate each option
        options[row, col].each do |an_option|

          # Save the state of the board, this is
          # necessary because calculate_options()
          # mangles the board.
          old_board = Board.new( board )
           
          # Try this option
          board[row, col] = an_option

          # Recurse
          return true if brute_force
         
          # No solution. Revert to saved board
          # and try the next option.
          @board = old_board
        end

        break
      end

    end

    # Did we solve it?
    return true if board.valid? 
    false
  end

  def solve
    brute_force
  end
end

=begin rdoc
Example code using this library. Reads a Sudoku-board file 
from the command-line and solves it.
=end

def Sudoku.main
  puts "Ruby Sudoku Solver - 12 Aug 2005"
  puts "Mohit Muthanna Cheppudira <mohit@muthanna.com>"
  puts

  unless ARGV[0]
    puts "Usage: #{$0} filename"
    exit
  end

  # Load the board directly into the Solver.
  solver = Solver.new( Csv.new().load( ARGV[0] ))

  # Display the unsolved board.
  puts "Problem:"
  puts solver.board
  
  if solver.solve
    puts "\nSolution:"
  else
    puts "\nNo Solution. Best match:"
  end

  # Display the final board.
  puts solver.board
end

Sudoku.main

end
