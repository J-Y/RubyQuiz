#!/usr/bin/env ruby
# -*- ruby -*-

Num = 14

class Bingo
  def initialize
    @width = 9
    @height = 3
    @field = [[0,0,0],[0,0,0],[0,0,0],
              [0,0,0],[0,0,0],[0,0,0],
              [0,0,0],[0,0,0],[0,0,0]]
  end

  def insert_numbers
    0.upto (@width-1) { |x|
      arr = ((x*10)..((x*10)+10)-1).to_a
      # Special cases: don't insert a 0, add 90 to the row with 80
      arr.delete(0)
      if arr.index(89) != nil
	arr = arr + [90]
      end

      0.upto (@height-1) { |y|
	r = arr[rand (arr.length)]
	arr.delete(r)
	@field[x][y] = r
      }
      @field[x].sort!
    }
  end

  def remove_some
    0.upto(@height-1) { |x|
      cnt = 0
      while cnt < 4 
	cnt+=1
	r = rand @field.length
	# The following crap eludes `three in a row'
	if @field[r][x] != nil &&
	    !((@field[r][0] == nil && @field[r][1] == nil) ||
 	      (@field[r][1] == nil && @field[r][2] == nil) ||
	      (@field[r][2] == nil && @field[r][0] == nil))
	  @field[r][x] = nil
	else
	  cnt-=1
	end
      end
      0.upto (@width-1) { |y|
      }
    }
    puts
  end

  def dump
    0.upto(@height-1) { |x|
      0.upto(@width-1) { |y|
	value = @field[y][x]
	if (0..9).to_a.index(value) != nil
	  value = '?' + value.to_s
	end
	if value == nil
	  value = '\X'
	end
	print "&& ", value, " "
      }
      if x != @height-1
	print "&\\nl\n"
      else
	print "&\\newsheet\n"
      end
    }
  end
end

Num.times {
  b = Bingo.new
  b.insert_numbers
  b.remove_some
  b.dump
}
