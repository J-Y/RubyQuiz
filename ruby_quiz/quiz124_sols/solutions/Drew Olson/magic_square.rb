# file: magic_square.rb
# author: Drew Olson

class MagicSquare

  # access to the raw square (not used here, maybe used by others?)
  attr_reader :square

  # check that size is odd, then store size and build our square
  def initialize size
    raise "Size must be odd" unless size%2 == 1
    @size = size
    @square = build_square size
    self
  end

  # scary looking method for pretty printing
  def to_s
    # find the largest number of digits in the numbers we
    # are printing
    digits = max_digits @size**2

    # create the row divider. flexible based on size of numbers
    # and the square.
    divider = "+"+("-"*(@size*(3+digits)-1))+"+\n"

    # build each row by formatting the numbers to the max
    # digits needed and adding pipe dividers
    (0...@size).inject(divider) do |output,i|
      output + "| " +
        @square[i].map{|x| "%#{digits}d" % x}.join(" | ") +
        " |\n" + divider
    end
  end

  private

  # get the highest digit count up to size
  def max_digits size
    (1..size).map{|x| x.to_s.size}.max
  end

  # build square based on the algorithm from wikipedia.
  # start in the middle of the first row, move up and right.
  # if new space is occupied, move down one space and continue.
  def build_square size
    #starting positions
    x,y = size/2,0

    # build square
    (1..size**2).inject(Array.new(size){[]}) do |arr,i|

      # store current number in square
      arr[y][x] = i

      # move up and left
      x = (x+1)%size
      y = (y-1)%size

      # undo move and move down if space is taken
      if arr[y][x]
        y = (y+2)%size
        x = (x-1)%size
      end
      arr
    end
  end
end

# build and print out square
if __FILE__ == $0
  puts MagicSquare.new(ARGV[0].to_i)
end
