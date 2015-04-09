class Paper
  def initialize(width, height)
    @grid = Array.new(width) { Array.new(height) }
    height.times { |y| width.times {|x| @grid[x][y] = [width*y+x+1] }}
  end

  def width; @grid.size; end
  def height; @grid[0].size; end

  def answer
    raise "Not enough folds" if width > 1 or height > 1
    @grid[0][0]
  end

  # Fold right side over to left
  def fold!
    raise "Bad input" if width%2 == 1
    @grid = (0 .. (width / 2 - 1)).map { |col|
      @grid[col].zip(@grid[width - col - 1]).map {|pair| pair[1].reverse + pair[0]}
    }
  end

  # 90 degree counter clockwise rotation
  def rotate!
    @grid = @grid.transpose.map{|c| c.reverse}
  end
end

def fold(width, height, commands)
  turns = commands.tr('RBLT', '0123').split(//).map{|x| x.to_i}
  paper = Paper.new(width, height)
  turns.each { |turn|
    4.times {|i|
      paper.fold! if i==turn
      paper.rotate!
    }
  }    
  paper.answer
end
