class Array
  def reverse_each
    map {|x| x.reverse}
  end
end

def fold(str,w=8,h=8)
  grid = Array.new(h) {|y| Array.new(w) {|x| [w*y+x+1] }  }
  str.each_byte {|c|
    grid = case c
	  when ?R then rightFold(grid)
	  when ?L then rightFold(grid.reverse_each).reverse_each
	  when ?B then rightFold(grid.transpose).transpose
  	  when ?T then rightFold(grid.reverse.transpose).transpose.reverse
	end
  }
  raise "invalid folding instructions" unless grid.length == 1 && grid[0].length == 1
  return grid[0][0]
end

def rightFold(grid)
  grid.map { |row|
    for ix in 0...row.length/2
	  row[ix] = row[-ix-1].reverse + row[ix]
	end
    row[0...row.length/2]
  }
end

p fold("RB",2,2)
p fold("TLRBB",4,8)
p fold("TLBLRRTB",16,16)
