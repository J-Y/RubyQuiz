#!/usr/bin/env ruby
#
# Jesse Brown
#
# Again, dynamic programing allows for a confortable time.
# The entire matrix can be calulated in O(n^2). But we need to 
# allow for any index into the matrix to be the origin.
# O(n^4)
#
# Limitations:
# While this could easily be adapted for rectangular matricies,
# only square matricies are supported at the moment. 
# Could probably be worked down close to O(n^3)
#

SIZE = 4    # SIZE x SIZE matrix

# Small printing utility.
def print_matrix(tl, br, matrix, full=false)
   r1, c1 = tl[0], tl[1]
   r2, c2 = br[0], br[1]

   puts "Matrix sized #{r2-r1+1}x#{c2-c1+1}:"
   
   # Printing a sub-matrix
   if not full
      puts "Top left index of smaller matrix in larger matrix     : [#{r1}, #{c1}]"
      puts "Bottom right index of smaller matrix in larger matrix : [#{r2}, #{c2}]"
   end
   puts

   # Single element
   if tl == br
      puts "[ " + matrix[r1][c1].to_s + " ]"
      return
   end

   (r1..r2).each { |row| puts "[ " + matrix[row][c1..c2].join(" , ") + " ]" }
   puts "="*20
end

# (row,col) represents the top left of the sub_matrix 
# to be calculated out of matrix
def sub_matrix(row,col,matrix)
   
   max, _row, _col = matrix[row][col], row, col
   m = []
   
   # Zero-out the array
   (0..(SIZE - 1)).each { |r| m[r] = [0]*SIZE }

   # Allows us to work across the rows in a nicer way
   (row..(SIZE - 1)).each { |r| m[r][col] = matrix[r][col] }

   # Calculate sums across all rows of the sub matrix
   (row..(SIZE - 1)).each do |r|
      ((col+1)..(SIZE - 1)).each do |c|
         m[r][c] = m[r][c - 1] + matrix[r][c]
         max, _row, _col = m[r][c], r, c if m[r][c] >= max
      end
   end
   
   # Now transform that new matrix as we calculate over it
   ((row+1)..(SIZE - 1)).each do |r|
      (col..(SIZE - 1)).each do |c|
         max, _row, _col = m[r][c], r, c if (m[r][c] += m[r-1][c]) > max
      end
   end
   
   # give back the value and the bottom right index
   return [max, _row, _col]
         
end

a = [
   [1, -1, 4, 1],
   [-1, 1, 1, -1],
   [1, 5, 1, -1],
   [-2, -1, -1, -2]]
max = a[0][0]
r1, r2, c1, c2 = 0, 3, 0, 3
print_matrix([0,0], [3,3], a, true)
(0..3).each do |row|
   (0..3).each do |col|
      data = sub_matrix(row,col,a)
      if data[0] >= max
         max = data[0]
         r1, c1 = row, col
         r2, c2 = data[1], data[2]
      end
   end
end
print_matrix([r1,c1], [r2,c2], a)
