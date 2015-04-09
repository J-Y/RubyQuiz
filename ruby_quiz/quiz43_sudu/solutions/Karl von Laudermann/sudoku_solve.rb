#!/usr/bin/env ruby
#
# =Description
#
# Solves a Su Doku puzzle. Prints the solution to stdout.
#
# =Usage
#
#   sudoku_solve.rb <puzzle.txt>
#
# puzzle.txt is a text file containing a sudoku puzzle in the following format:
#
#   +-------+-------+-------+
#   | _ _ 2 | _ _ 5 | _ 7 9 |
#   | 1 _ 5 | _ _ 3 | _ _ _ |
#   | _ _ _ | _ _ _ | 6 _ _ |
#   +-------+-------+-------+
#   | _ 1 _ | 4 _ _ | 9 _ _ |
#   | _ 9 _ | _ _ _ | _ 8 _ |
#   | _ _ 4 | _ _ 9 | _ 1 _ |
#   +-------+-------+-------+
#   | _ _ 9 | _ _ _ | _ _ _ |
#   | _ _ _ | 1 _ _ | 3 _ 6 |
#   | 6 8 _ | 3 _ _ | 4 _ _ |
#   +-------+-------+-------+
#
# Characters '-', '+', '|', and whitespace are ignored, and thus optional. The
# file just has to have 81 characters that are either numbers or other 
# printables besides the above mentioned. Any non-numeric character is 
# considered a blank (unsolved) grid entry.
#
# The puzzle can also be passed in via stdin, e.g.:
#   cat puzzle.txt | sudoku_solve.rb

require 'rdoc/usage'

#==============================================================================
# ----- Classes -----
#==============================================================================

class UnsolvableException < Exception
end

# Represents one grid space. Holds known value or list of candidate values.
class Space
    def initialize(num = nil)
        @value = num
        @cands = num ? [] : [1, 2, 3, 4, 5, 6, 7, 8, 9]
    end

    def value() @value end
    def value=(val) @value = val; @cands.clear end
    def remove_cand(val) @cands.delete(val) end
    def cand_size() @cands.size end
    def first_cand() @cands[0] end
end

# Represents puzzle grid. Grid has 81 spaces, composing 9 rows, 9 columns, and 
# 9 "squares":
#
#                                      Colums
#            Spaces                  012 345 678
#                  
#   0  1  2| 3  4  5| 6  7  8      0    |   |   
#   9 10 11|12 13 14|15 16 17      1  0 | 1 | 2  <- Squares
#  18 19 20|21 22 23|24 25 26      2    |   |         |
#  --------+--------+--------    R   ---+---+---      |
#  27 28 29|30 31 32|33 34 35    o 3    |   |         |
#  36 37 38|39 40 41|42 43 44    w 4  3 | 4 | 5  <----+
#  45 46 47|48 49 50|51 52 53    s 5    |   |         |
#  --------+--------+--------        ---+---+---      |
#  54 55 56|57 58 59|60 61 62      6    |   |         |
#  63 64 65|66 67 68|69 70 71      7  6 | 7 | 8  <----+
#  72 73 74|75 76 77|78 79 80      8    |   |
class Board
    # Stores which spaces compose each square
    @@squares = []
    @@squares[0] = [ 0,  1,  2,  9, 10, 11, 18, 19, 20].freeze
    @@squares[1] = [ 3,  4,  5, 12, 13, 14, 21, 22, 23].freeze
    @@squares[2] = [ 6,  7,  8, 15, 16, 17, 24, 25, 26].freeze
    @@squares[3] = [27, 28, 29, 36, 37, 38, 45, 46, 47].freeze
    @@squares[4] = [30, 31, 32, 39, 40, 41, 48, 49, 50].freeze
    @@squares[5] = [33, 34, 35, 42, 43, 44, 51, 52, 53].freeze
    @@squares[6] = [54, 55, 56, 63, 64, 65, 72, 73, 74].freeze
    @@squares[7] = [57, 58, 59, 66, 67, 68, 75, 76, 77].freeze
    @@squares[8] = [60, 61, 62, 69, 70, 71, 78, 79, 80].freeze
    @@squares.freeze

    # Takes a string containing the text of a valid puzzle file as described in 
    # the Usage comment at the top of this file
    def initialize(grid = nil)
        @spaces = Array.new(81) { |n| Space.new }

        if grid
            count = 0
            chars = grid.split(//).delete_if { |c| c =~ /[\+\-\|\s]/ }

            chars.each do |c|
                set(count, c.to_i) if c =~ /\d/
                count += 1
                break if count == 81
            end
        end
    end

    def set(idx, val)
        @spaces[idx].value = val
        adjust_cands_from(idx)
    end

    # Remove indicated space's value from candidates of all spaces in its 
    # row/col/square
    def adjust_cands_from(sidx)
        val = @spaces[sidx].value

        row_each(which_row(sidx)) do |didx|
            @spaces[didx].remove_cand(val)
        end

        col_each(which_col(sidx)) do |didx|
            @spaces[didx].remove_cand(val)
        end

        square_each(which_square(sidx)) do |didx|
            @spaces[didx].remove_cand(val)
        end
    end

    # Return number of row/col/square containing the given space index
    def which_row(idx) idx / 9 end
    def which_col(idx) idx % 9 end

    def which_square(idx)
        @@squares.each_with_index { |s, n| return n if s.include?(idx) } 
    end

    # Yield each space index in the row/col/square indicated by number
    def row_each(row) ((row * 9)...((row + 1) * 9)).each { |n| yield(n) } end
    def col_each(col) 9.times { yield(col); col += 9 } end
    def square_each(squ) @@squares[squ].each { |n| yield(n) } end

    def solved?() @spaces.all? { |sp| sp.value } end

    # For each empty space that has only one candidate, set the space's value to 
    # that candidate and update all related spaces. Repeat process until no 
    # empty spaces with only one candidate remain
    def deduce_all
        did = true

        while did
            did = false

            @spaces.each_index do |idx|
                sp = @spaces[idx]

                raise UnsolvableException if ((!sp.value) && sp.cand_size == 0)
                if (sp.cand_size == 1)
                    sp.value = sp.first_cand
                    adjust_cands_from(idx)
                    did = true
                end
            end
        end
    end

    def to_s
        div = "+-------+-------+-------+\n"
        ret = "" << div

        @spaces.each_index do |idx|
            ret << "|" if (idx % 9 == 0)
            ret << " " + (@spaces[idx].value || '_').to_s
            ret << " |" if (idx % 3 == 2)
            ret << "\n" if (idx % 9 == 8)
            ret << div if ([26, 53, 80].include?(idx))
        end

        ret
    end

    def solve()
        # Solve
        deduce_all
        return if solved?

        # Find an unsolved space with the fewest candidate values and store its 
        # index and first candidate
        min_count = nil
        test_idx = nil

        @spaces.each_with_index do |sp, n|
            if !sp.value
                if (!min_count) || (sp.cand_size < min_count)
                    test_idx, min_count = n, sp.cand_size
                end
            end
        end

        test_cand = @spaces[test_idx].first_cand

        # Solve clone of board in which the value of the space found above is 
        # set to it's first candidate value
        str = ""

        @spaces.each_index do |idx|
            str << (idx == test_idx ? test_cand.to_s :
                (@spaces[idx].value || '_').to_s)
        end

        b_clone = Board.new(str)

        begin
            b_clone.solve
            initialize(b_clone.to_s) # Take state from clone
        rescue UnsolvableException
            @spaces[test_idx].remove_cand(test_cand)
            solve
        end
    end
end

#==============================================================================
# ----- Script start -----
#==============================================================================

b_str = ARGF.readlines().join()
board = Board.new(b_str)

begin
    board.solve()
    puts board.to_s
rescue UnsolvableException
    puts "This puzzle has no solution!"
end
