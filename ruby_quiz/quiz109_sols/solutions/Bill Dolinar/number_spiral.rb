#!/usr/bin/env ruby
# Script to print an N by N spiral as shown in the following example:
#
#  56   57   58   59   60   61   62   63
#
#  55   30   31   32   33   34   35   36
#
#  54   29   12   13   14   15   16   37
#
#  53   28   11    2    3    4   17   38
#
#  52   27   10    1    0    5   18   39
#
#  51   26    9    8    7    6   19   40
#
#  50   25   24   23   22   21   20   41
#
#  49   48   47   46   45   44   43   42
#
# Let item with value 0 be at x, y coordinate (0, 0).  Consider the
# spiral to be rings of numbers.  For the numbers 1 through 8 make
# up ring level 1, and numbers 9 through 24 make up ring level 2.
# To figure out the value at a particular x, y position, note that
# the first value at any level is (2 * level - 1) ** 2 and use that
# value to count up or down to the coordinate.

class Spiral

  def initialize(size)
    @size = size
    @center = size/2
  end

  # returns the value for a given row and column of output
  def position_value(row, col)
    x, y = coordinate = coordinate_for(row, col)
    level = [x.abs, y.abs].max
    if x < level && y > -level
      # return number for top left portion of ring
      first_number(level) +
          steps_between(first_coordinate(level), coordinate)
    else
      last_number(level) -
          steps_between(last_coordinate(level), coordinate)
    end
  end

  def maximum_value
    @size * @size - 1
  end

  def first_number(level)
    (2 * level - 1) ** 2
  end

  def last_number(level)
    first_number(level + 1) - 1
  end

  def first_coordinate(level)
    [-level, -level + 1]
  end

  def last_coordinate(level)
    [-level, -level]
  end

  def coordinate_for(row, col)
    [col - @center, @center - row]
  end

  def steps_between(point1, point2)
    (point1[0] - point2[0]).abs + (point1[1] - point2[1]).abs
  end
end


if __FILE__ == $0
  size = ARGV[0].to_i
  spiral = Spiral.new(size)
  width = spiral.maximum_value.to_s.length + 3
  (0...size).each do |row|
    (0...size).each do |col|
      print spiral.position_value(row, col).to_s.rjust(width)
    end
    print "\n\n"
  end
end
