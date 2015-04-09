#!/usr/bin/ruby

require 'Matrix'

# Extend Fixnum to have method reverse to avoid unneccessary checking later
class Fixnum
  def reverse
    self
  end
end

class Grid
  attr_reader :grid
  # Assume correct dimensions. The caller method takes care of checking input 
  # size
  def initialize (dimension1,dimension2)
    @grid = Matrix.rows((0...dimension2).collect{ |i| 
      ((1+i*dimension1)..(i+1)*dimension1).to_a })
  end

  # Main function to be called from outside
  def apply_fold(string)
    instructions = string.split("")
    instructions.each do |dir|
      case dir
      when "B"
        fold_bottom
      when "T"
        fold_top
      when "R"
        fold_right
      when "L"
        fold_left
      end
    end
    @grid.to_a.flatten
  end

  # Avoid the trouble of flattening each element while folding
  # Simply flatten after folding
  def flatten_grid
    height = grid.row_size
    width = grid.column_size
    for i in 0...height
      for j in 0...width
        @grid[i,j].flatten!
      end
    end
  end
  
  def fold_top
    height = grid.row_size
    top_grid = (-height/2+1..0).collect do
      |x| grid.row(-x).to_a.collect{ |y| y.reverse }
    end
    bottom_grid = (height/2...height).collect{ |x| grid.row(x).to_a }
    #     p top_grid
    #     p bottom_grid
    @grid = (0...height/2).collect{ |i| top_grid[i].zip bottom_grid[i] }
    @grid = Matrix.rows(@grid)
    flatten_grid
  end

  def fold_bottom
    height = grid.row_size
    top_grid = (0...height/2).collect{ |x| grid.row(x).to_a }
    bottom_grid = (-height+1..-height/2).collect do |x| 
      grid.row(-x).to_a.collect{ |y| y.reverse }
    end
    #     p top_grid
    #     p bottom_grid
    @grid = (0...height/2).collect{ |i| bottom_grid[i].zip top_grid[i] }
    @grid = Matrix.rows(@grid)
    flatten_grid
  end

  def fold_left
    width = grid.column_size
    left_grid = (-width/2+1..0).collect do |x| 
      grid.column(-x).to_a.collect{ |y| y.reverse }
    end
    right_grid = (width/2...width).collect{ |x| grid.column(x).to_a }
    #     p left_grid
    #     p right_grid
    @grid = (0...width/2).collect{ |i| left_grid[i].zip right_grid[i] }
    @grid = Matrix.rows(@grid).transpose
    flatten_grid
  end

  def fold_right
    width = grid.column_size
    left_grid = (0...width/2).collect{ |x| grid.column(x).to_a }
    right_grid = (-width+1..-width/2).collect do |x| 
      grid.column(-x).to_a.collect{ |y| y.reverse}
    end
    #     p left_grid
    #     p right_grid
    @grid = (0...width/2).collect{ |i| right_grid[i].zip left_grid[i] }
    @grid = Matrix.rows(@grid).transpose
    flatten_grid
  end
end

# Main function to be called from outside
def fold(dim1, dim2, args)
  raise "bad input dimensions" unless power2?(dim1) && power2?(dim2)
  raise "too many vertical folds" unless  args.split("").find_all{ |x| x == "T" || x == "B" }.length == power2(dim1)
  raise "too many horizontal folds" unless args.split("").find_all{ |x| x == "L" || x == "R" }.length == power2(dim2)
  grid = Grid.new(dim1,dim2)
  grid.apply_fold(args)
end

def power2?(dimension)
  (Math.log(dimension)/Math.log(2)).ceil == (Math.log(dimension)/Math.log(2)).floor
end

def power2(dimension)
  (Math.log(dimension)/Math.log(2)).ceil
end
