# how many rows are we going to do?
rows = ARGV.shift.to_i

# calculate the number in the center of the last row; these calculations are
# based on a reduction of (n choose n/2). this is gauranteed to be the largest
# -- and thus longest -- number in the triangle.
n = rows - 1
p = n / 2
q = (n - p) + 1

denominator = (1..p).inject(1) { |acc,i| acc * i }
numerator   = (q..n).inject(1) { |acc,i| acc * i }
seed = numerator / denominator

# the box size is the length of the seed number, plus one for some aesthetic
# whitespace. indent blocks are just a block worth of whitespace; number blocks
# are double width with the number right alighed to the center line.
block_size = seed.to_s.length + 1
indent_block = ' ' * block_size
number_block = "%#{block_size}d" + indent_block

# we seed with an empty row, and start iterating
row = []
numbers = ''
rows.times do
  # we calculate the next row by combining the values from the previous, then
  # adding a leading one
  row.each_index{ |i| row[i] += row[i + 1] || 0 }
  row.unshift 1

  # tack another number block on the end for the extra one
  numbers << number_block

  # the indent *decreases* per row, and we just interpolate the values into
  # their blocks after the indent
  puts indent_block * (rows - row.size) + numbers % row
end
