#!/usr/bin/env ruby

class MagicSquare
  Coords = Struct.new(:x, :y)

	def initialize(size)
	  @size = size.to_i
	  @final_num = @size**2
	  @coords = Coords.new(@size/2, 0)

    create_square
	end

	def init_square
	 @square = []
	 1.upto(@size) do
	   @square << [0] * @size
   end
	end

	def create_square
	  init_square

	  n = 1
	  while n <= @final_num
	    @square[@coords.y][@coords.x] = n
	    n += 1
	    next_coords
    end
  end

	def to_s
	  output = []
	  num_length = @final_num.to_s.length
	  num_length+2 * @size
	  hline = '+' + Array.new(@size, '-' * (num_length + 2)).join('+') + '+'

	  output.push(hline)
	  (0...@size).each do |x|
	    output.push('| ' + @square[x].collect { |n| sprintf("%#{num_length}d", n) }.join(' | ') + ' |')
	    output.push(hline)
    end
    output.join("\n")
  end

  private
  def next_coords
    new_coords = Coords.new((@coords.x-1 + @size) % @size, (@coords.y-1 + @size) % @size)
    if @square[new_coords.y][new_coords.x] != 0
      new_coords = Coords.new(@coords.x, (@coords.y+1) % @size)
    end
    @coords = new_coords
  end
end


square = MagicSquare.new(ARGV[0])

puts square
