#! /usr/bin/ruby

# Nicolas Modrzyk May, 2007
# Magic Square Ruby Quiz 124: http://www.rubyquiz.com/quiz124.html

class MagicSquare
  def initialize size
    @size = size
    @matrix = Array.new(size)
    1.upto(size) do |e|
      @matrix[e-1] = Array.new(size,0)
    end
  end
  
  def print
    buffer = ""
    1.upto(@size) do |e|
      buffer << @matrix[e-1].join(":") + "\n"
    end
    puts buffer
  end
  
  def build 
    raise "Choose Implementation Class"
  end
  
  def is_magic?
    total_row = nil
    total_col = nil
    
    0.upto(@size-1) do |e|
      tr = @matrix[e].inject(0) {|sum,i|  sum + i }
      return false if not total==nil and not t==total
      total_row = tr 
    end
    
    true
  end
 
end

class LoubereSquare < MagicSquare  
  
  def build
    @current = [0,@size/2,1]
    1.upto(@size*@size) do |e|
      @matrix[@current[0]][@current[1]] = @current[2]
      compute_next_current
    end
  end
 
  private
  def compute_next_current
    # get the square at the top right corner from current position
    col = (@current[1] + 1)%@size
    row = (@current[0] - 1)%@size
    
    # go to the position below if the new position has already been filled
    if not (@matrix[row][col] == 0)
      row = (@current[0] + 1)%@size
      col = @current[1]
    end
    
    # update new position and value
    @current = [row, col, @current[2]+1]
  end
  
end

if $0 == __FILE__ 
  size = ARGV[0].to_i
  raise "Not an odd number" if size%2==0 
  matrix = LoubereSquare.new(size)
  matrix.build
  matrix.print
end
