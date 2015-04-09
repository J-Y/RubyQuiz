rows		= (ARGV.shift || 10).to_i						# The number of rows: >=1
sierpinski	= (ARGV.shift || 0).to_i						# Sierpinski: =>0
excentricity	= (ARGV.shift || 0.0).to_f						# Excentricity: -1.0..+1.0

sierpinski	= 2	if sierpinski == 1						# Prevent an empty output.

fac	= lambda{|n| n <=1 ? 1 : (1..n).inject{|a, b| a*b}}				# Faculty of n.
cell	= lambda{|r, c| fac[r-1]/fac[c-1]/fac[r-c]}					# The content of a specific cell.
biggest	= cell[rows, rows/2+1]								# The biggest number in the last row.
width	= biggest.to_s.length								# The width of each cell...
width	+=1	if width % 2 == 0							# ...but it shouldn't be even.
width	= 1	if sierpinski > 0

(1..rows).inject([1]) do |row, row_nr|							# Start with row=[1].
  line =
  (0...row_nr).map do |cell_nr|								# Each cell should have the correct width.
    cell	= row[cell_nr].to_s							# Get the contents of the cell.
    cell	= row[cell_nr]%sierpinski==0 ? " " : "*"	if sierpinski > 0
    rhs = !lhs	= cell_nr < row_nr/2							# Are we in the right hand side or in the left hand side of the triangle?
    left	= (width+1 - cell.length)/2	if lhs					# Number of padding characters at the left, within the cell, erroring to the right.
    left	= (width+0 - cell.length)/2	if rhs					# Number of padding characters at the left, within the cell, erroring to the left.
    right	= (width - cell.length - left)

    " "*left + cell + " "*right								# The new contents of the cell.
  end.join(" ")										# Join the cells into a line.

  left		= (rows - row_nr) * (width/2+1)						# Number of padding characters at the left, on the line.
  left		= (excentricity + 1.0) * left						# "Lean" to the left, or to the right.
  line		= " "*left + line

  margin	= width/2								# Half the cell width...
  line		= line[margin...-margin]	unless sierpinski > 0			# ...can be stripped at the left and at the right of the line.

  puts line										# Print it!

  ([0]+row).zip(row+[0]).map{|a, b| a+b}	unless row_nr == rows			# Build the next row. It's explained below.
end
