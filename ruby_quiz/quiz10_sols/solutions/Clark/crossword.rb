#!/usr/bin/env ruby

class GraphicBlock
  attr_reader :arr

  def initialize(arr)
    @arr = arr
  end

  def add_right(other)
    result = @arr.zip(other.arr).collect do |line|
      line.join("")
    end
    GraphicBlock.new(result)
  end

  def add_below(other)
    GraphicBlock.new(@arr + other.arr)
  end

  def transpose
    result = @arr.collect { |row| row.split(//) }.
      transpose.collect { |line| line.join("") }
    GraphicBlock.new(result)
  end

  def collapse_column_borders(cell_width)
    result = @arr.each do |line|
      (line.size/cell_width).downto(1) do |i|
	border = (i*cell_width) - 1
	line[border, 2] = line[border, 2].include?("#") ? "#" : " "
      end
    end
    GraphicBlock.new(result)
  end

  def collapse_row_borders(cell_height)
    transpose.collapse_column_borders(cell_height).transpose
  end

  def to_s
    @arr.join("\n")
  end
end


class Crossword
  attr_reader :cell_width, :cell_height

  def initialize(filename, cell_width = 6, cell_height = 4)
    @cell_width = cell_width
    @cell_height = cell_height
    @puzzle = Array.new
    IO.foreach(filename) do |line|
      line = line.chomp.gsub(/ /, '')
      @puzzle << (row = Array.new)
      line.split('').each do |char|
	if (char == "X")
	  row << :filled
	else
	  row << :letter
	end
      end
    end
    remove_filled_border
    number_puzzle
  end

  def cell(i, j)
    if (i < 0 || i >= @puzzle.size ||
	j < 0 || j >= @puzzle[i].size)
      nil
    else
      @puzzle[i][j]
    end
  end

  def above(i, j)  cell(i-1, j)   end
  def below(i, j)  cell(i+1, j)   end
  def left(i, j)   cell(i, j-1)   end
  def right(i, j)  cell(i, j+1)   end

  def adjacent(i, j)
    [above(i, j), below(i, j), left(i, j), right(i, j)]
  end

  def unused_cell?(item)
    (item == nil) || (item == :filled)
  end

  def letter_cell?(item)
    !unused_cell?(item)
  end

  def puzzle_visit
    @puzzle.each_with_index do |row, i|
      row.each_with_index do |item, j|
	yield(item, i, j)
      end
    end
  end

  def remove_filled_border
    begin
      changed = false
      puzzle_visit do |item, i, j|
	if (item == :filled && adjacent(i, j).include?(nil))
	  @puzzle[i][j] = nil
	  changed = true
	end
      end
    end while (changed)
  end

  def number_puzzle
    count = 1
    puzzle_visit do |item, i, j|
      if (letter_cell?(item) &&
	  ((unused_cell?(above(i, j)) && letter_cell?(below(i, j))) ||
	   (unused_cell?(left(i, j)) && letter_cell?(right(i, j)))))
	@puzzle[i][j] = count
	count += 1
      end
    end
  end

  def graphics(item)
    arr = Array.new
    if (item == :filled)
      cell_height.times { |i| arr << "#" * cell_width }
    elsif (item == :letter)
      arr << "#" * cell_width
      (cell_height-2).times { |i|
	arr << "#" + " " * (cell_width-2) + "#"
      }
      arr << "#" * cell_width
    elsif (item != nil && item.integer?)
      arr << "#" * cell_width
      arr << sprintf("#%-*d#", cell_width-2, item)
      (cell_height-3).times { |i|
	arr << "#" + " " * (cell_width-2) + "#"
      }
      arr << "#" * cell_width
    else
      cell_height.times { |i| arr << " " * cell_width }
    end
    GraphicBlock.new(arr)
  end

  def draw_raw
    @puzzle.collect do |row|
      row.collect { |cell| graphics(cell) }.inject do |row_picture, g|
	row_picture.add_right(g)
      end
    end.inject do |full_picture, row_picture|
      full_picture.add_below(row_picture)
    end
  end

  def draw
    draw_raw.collapse_column_borders(cell_width).
      collapse_row_borders(cell_height)
  end
end

if __FILE__ == $0
  puzzle = Crossword.new(ARGV.first)
  print puzzle.draw.to_s + "\n"
end
