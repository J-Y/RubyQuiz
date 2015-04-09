#! /usr/bin/env ruby -w

require 'enumerator'


# Fold up matrix of numbers using given directions where directions
# are in a string with T = top, B = bottom, L = left, R = right:
# "TLBR".  Throws ArgumentError on invalid direction or rows or cols
# not a power of 2.
def fold(directions, rows=16, cols=16)
  check_rows_and_cols(rows, cols)
  if (directions =~ /[^TLBR]/)
    raise ArgumentError, "Invalid direction given"
  end

  # build array of values
  # using each_slice as described by Levin Alexander
  values = (1..rows*cols).to_enum(:each_slice, 1).to_a
  values = values.to_enum(:each_slice, cols).to_a

  fold_matrix = FoldMatrix.new(values)

  directions.split(//).each do |direction|
    fold_matrix.fold(direction)
  end
  fold_matrix.result
end

# Get the folding directions from a fold array.  The item that has
# never been folded over is at end of array.  The item that wasn't
# folded until the last fold and is now at at the first of array.
# Can iterate through last folded by continually cutting array in
# half.  Throws ArgumentError on array not in fold order or rows or
# cols not power of 2.
def check_fold(fold_result, rows=16, cols=16)
  check_rows_and_cols(rows, cols)

  directions = ""
  folded = 0
  size = fold_result.size
  while folded < fold_result.size - 1
    # get direction in original matrix from last to first
    directions << direction_to(fold_result.last, fold_result[folded], cols)

    # move to next item last folded
    size = size/2
    folded += size
  end
  directions.reverse
end


class FoldMatrix

  attr_reader :values

  def initialize(values)
    @values = values
  end

  # Return a new fold matrix by folding in direction where direction
  # is one of :left, :right, :top, :bottom.
  def fold(direction)
    case direction
      when "L"
        left, @values = split_along_v
        flip_along_v(left)
        place_over(left)
      when "R"
        @values, right = split_along_v
        flip_along_v(right)
        place_over(right)
      when "T"
        top, @values = split_along_h
        flip_along_h(top)
        place_over(top)
      when "B"
        @values, bottom = split_along_h
        flip_along_h(bottom)
        place_over(bottom)
    end
  end

  # Return the result of folding in flattened array
  def result
    if (@values.size != 1 && @values[0].size != 1)
      raise ArgumentError, "Paper not completely folded"
    end
    @values.flatten
  end

protected

  def split_along_v
    left = []
    right = []
    cols = @values[0].size
    @values.each do |row|
      left << row[0...cols/2]
      right << row[cols/2...cols]
    end
    return left, right
  end

  def split_along_h
    rows = @values.size
    top = @values[0...rows/2]
    bottom = @values[rows/2...rows]
    return top, bottom
  end

  def flip_along_v(a)
    a.each do |row|
      row.reverse!
      row.each {|item| item.reverse!}
    end
  end

  def flip_along_h(a)
    a.reverse!
    a.each {|row| row.each {|item| item.reverse!}}
  end

  def place_over(top)
    top.each_with_index do |row, i|
      row.each_with_index do |item, j|
        @values[i][j] = item + @values[i][j]
      end
    end
  end
end

# Determine if a number is a power of 2
def is_power_of_2(number)
  return false if number < 1

  # keep on shifting left until number equals one (power of 2) or has
  # one bit set but isn't one (not power of 2)
  while number > 1
    number >>= 1
    return false if ((number & 1) == 1 && number != 1)
  end
  true
end

def coordinate(index, cols)
  index -= 1
  i, j = index/cols, index%cols
end

# Get the direction from an unfolded matrix element to the one
# just folded to the top.  Both must be in same row or column.
def direction_to(unfolded, folded, cols)
  unfolded_i, unfolded_j = coordinate(unfolded, cols)
  folded_i,   folded_j   = coordinate(folded, cols)

  i_compare = unfolded_i <=> folded_i
  j_compare = unfolded_j <=> folded_j

  case [i_compare, j_compare]
    when [ 0,  1] then "L"
    when [ 0, -1] then "R"
    when [ 1,  0] then "T"
    when [-1,  0] then "B"
    else
      raise ArgumentError, "Values not in same row or column: " +
                           "#{unfolded}, #{folded}, #{rows}x#{cols}"
  end
end

def check_rows_and_cols(rows, cols)
  unless is_power_of_2(rows)
    raise ArgumentError, "Rows must be power of two"
  end
  unless is_power_of_2(cols)
    raise ArgumentError, "Cols must be power of two"
  end
end
