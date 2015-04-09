#!/usr/bin/ruby -w
#########################
# Author: Christian Roese
# Filename: magicsquare.rb
# Date: 20-05-07
#########################
# Ruby Quiz #124 - Magic Squares

# behold, a rhodes magic square class!
class MagicSquare
 def initialize(size)
   @size = size
   @square = Array.new(size)
   @square.each_index { |i| @square[i] = Array.new(size, 0) }  # create multidimensional array of zeroes
   # let's get started building this thing
   create
 end

 # primary function in this class; takes care of all the legwork by filling in the magic
 # square with successive numbers
 def create
   stop = @size ** 2
   row = 0
   col = (@size - 1) / 2     # handy trick to find middle of zero-based array
   1.upto(stop) do |num|
     @square[row][col] = num
     temp_row, temp_col = row - 1, col - 1
     temp_row = @size - 1 if temp_row < 0    # handle going off the deep end and adjust accordingly
     temp_col = @size - 1 if temp_col < 0    # ...and here, too
     if @square[temp_row][temp_col] != 0     # check if prospective spot is already filled
       temp_row, temp_col = row + 1, col     # if so, move down one spot from initial square
     end
     # get ready for next iteration
     row = temp_row
     col = temp_col
   end
 end

 # pretty-printing function that displays the magic square in a box
 # looks alright until numbers get above 1,000...
 def pp
   rowsep = "+" + "-" * (@size * 6 - 1) + "+"  # IMPROVE ME: more dynamic string for larger squares - perhaps dependent on @size^2
   rowfmt = "|" + " %3d |" * @size +"\n"       # IMPROVE ME: more dynamic string for larger squares - perhaps dependent on @size^2
   puts rowsep
   @square.each do |sub|
     printf(rowfmt, *sub)
     puts rowsep
   end
 end

 # helper function to check row sum
 def magic_number(row=0)
   @square[row].inject { |sum, n| sum + n }
 end
 private :create
end

# grab cmd-line arg and convert it to a number
# NOTE: if to_i fails here, it returns a 0 which is then caught by the if-then clause - no exceptions needed!
input = ARGV.shift.to_i

# prevent bad input
# NOTE: ignoring size == 1 since it's a trivial square
E_BADARG = 1
if input <= 2 || input % 2 == 0
 puts "Bad argument - must be an odd integer > 2"
 exit E_BADARG
end

# make a new square, print it fancily(?), and spit out the magic number for kicks
sq = MagicSquare.new(input)
sq.pp
puts "magic number = #{sq.magic_number}"
