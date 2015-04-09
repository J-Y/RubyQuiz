#!/usr/bin/ruby -w
# @param  . width of square
# @param  . starting row
# @param  . starting column

class Square < Array
  def initialize aWidth
    super(aWidth) { Array.new aWidth }
    @mark = 0
    @size = aWidth ** 2
  end

  # Walks this square, from the given position,
  # while marking unmarked (nil) cells.
  def walk row, col
    # skip invalid positions and marked cells
      return false if
        row < 0 or row >= length or
        col < 0 or col >= length or
        self[row][col]

    # mark the current cell
      self[row][col] = @mark += 1

    # explore adjacent paths
      if @mark >= @size or
         walk(row + 3, col    ) or # east
         walk(row + 2, col - 2) or # north east
         walk(row,     col - 3) or # north
         walk(row - 2, col - 2) or # north west
         walk(row - 3, col    ) or # west
         walk(row - 2, col + 2) or # south west
         walk(row,     col + 3) or # south
         walk(row + 2, col + 2)    # south east

        true
      else
        # unmark the current cell
          @mark -= 1
          self[row][col] = nil

        false
      end
  end

  # Pretty-prints this square.
  def to_s
    # pretty-print each row
      fmt = '|' << "%#{length.to_s.length * 2}d " * length << '|'

      lines = inject([]) do |memo, row|
        memo << fmt % row
      end

    # add a border to top & bottom
      border = '-' * lines.first.length

      lines.unshift border
      lines << border

    lines.join("\n")
  end
end

if $0 == __FILE__
  # create a square with user's parameters
    width = (ARGV.shift || 5).to_i
    square = Square.new(width)

  # walk the square from random position
    origin = Array.new(2) { (ARGV.shift || rand(width)).to_i }
    square.walk(*origin)

  # pretty-print the walked square
    puts square.to_s
end
