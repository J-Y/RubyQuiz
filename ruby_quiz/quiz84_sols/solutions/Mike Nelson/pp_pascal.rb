# Pascal's Triangle (#84)
#   solution by Michael C Nelson
#
# The basic idea is that this takes advantage of the fact that empty cells can
# be represented as zeros. For example,
#
#             1                0 1 0
#            1 1   is like,   0 1 1 0
#           1 2 1            0 1 2 1 0
#          1 3 3 1            1 3 3 1
#
# In this way we can just populate the topmost 1 and basically get the other
# diagonal edge 1's for free just by going though each row below it one at a
# time, and for each cell adding the diagonal upper ones to that cell.
#
# This is taken a step further in that the spaces between each number can be
# zeros as well, like,
#
#             1
#            101
#           10201
#          1030301
#
# Since these are zeros as well we can sum up all the spaces in between them as
# well, because they will all turn out to be zero in the end. This makes the
# code a bit simpler.
#
# Also the zeros are not explicitly set but are implemented in the hash's
# default value block (each row is a hash). This also handles values outside of
# the specified size range and returns 0 to handle edge cases for the final
# row. Also this handles mirroring of the pyramid as only the left half
# (including the middle column) is stored in the hash rows. This allows the
# filling out of the pyramid section to only operate on the left half as an
# optimization.
#
# When printed, all zeros are displayed as spaces, to make the final printout
# of the pyramid.
#
#             1                     000010000
#            1 1   is really like,  000101000
#           1 2 1                   001020100
#          1 3 3 1                  010303010
#
# Also note that the 'size' defined for the hight of the pyramid is also the
# same as the width of half the pyramid plus the middle, this is used
# interchangeably in the code.

# get the size from the command line, or use default, helped in testing
size =  (ARGV[0] || 10).to_i
total_width = 2*size-1

# Build an empty pyramid. Only half of the pyramid is held in the Array of
# Hashes, the right half is just a mirror of the left.
pascal = (0..size).map do
  Hash.new do |hash, key|
    if key > size && key <= total_width
      # mirror it
      hash[2*size-key]
    else
      # for everything else we can't find return zero
      0
    end
  end
end

# Seed the pyramid (this is the topmost middle "1").
pascal[0][size] = 1

# Build out the pyramid starting from the top down to the bottom. This
# optimizes a bit by only adding one half of the pyramid, which is mirrored by
# the Array of Hashes. Also, this only adds the area in the pyramid in order to
# avoid adding a bunch of zeros in the upper unused sections (there is still a
# bunch of zero adding within the pyramid but this makes the code a bit
# simpler). Note:  this could add the whole area and it would still 
work.
cell_width = 0
(1...size).each do |y|
  (size-y..size).each do |x|
    value = pascal[y-1][x-1] + pascal[y-1][x+1]
    unless value.zero?
      pascal[y][x] = value
      cell_width = value.to_s.length if cell_width < value.to_s.length
    end
  end
end

# Print out the result based on the cell_width.
(0...size).each do |y|
  (1..total_width).each do |x|
    if pascal[y][x].zero?
      print " "*cell_width
    else
      printf("%#{cell_width}d", pascal[y][x])
    end
  end
  print "\n"
end
