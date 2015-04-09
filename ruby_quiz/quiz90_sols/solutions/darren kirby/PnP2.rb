#####################################
#!/usr/bin/ruby
# PnP.rb :: quiz no.90

class SolveIt
  def initialize(x,y,gridsize)
    @gridsize = gridsize
    @coords = [x,y]

    @moves_offset = {
      "l"  => [0,-3],
      "r"  => [0,3],
      "u"  => [-3,0],
      "d"  => [3,0],
      "ur" => [-2,2],
      "ul" => [-2,-2],
      "dr" => [2,2],
      "dl" => [2,-2]
    }

    @matrix = Array.new(@gridsize) { Array.new(@gridsize) { "." } }
    @matrix[@coords[0]][@coords[1]] = 1
    @totalnums = @gridsize*@gridsize
    @nextint = 2
  end

  def cell_free?(x,y)
    if x >= 0 && x < @gridsize && y >= 0 && y < @gridsize && 
                  @matrix[x][y] == "."
      return true
    else
      return false
    end
  end

  def num_moves(m)
    moves = 0
    x,y = @moves_offset[m]
    @moves_offset.each do |k,v|
      moves += 1 if cell_free?(@coords[0]+x+v[0],@coords[1]+y+v[1])
    end
    moves
  end

  def check_moves_and_return_best_one
    moves = []
    @moves_offset.each do |k,v|
      moves << k if cell_free?(@coords[0]+v[0],@coords[1]+v[1])
    end
    if moves.length == 0
       return nil
    elsif moves.length ==1
      return moves[0]
    end
    score = {}
    moves.each do |m|
      score[m] = num_moves(m)
    end
    score = score.invert.sort
    return score[0][1]
  end

  def print_matrix
    @matrix.each do |row|
      row.each do |cell|
        print " %3s " % cell
      end
      print "\n"
    end
  end

  def do_it
    @totalnums.times do
      move = check_moves_and_return_best_one
      if move == nil
        break # try again
      end
      x,y = @moves_offset[move]
      @coords[0] += x
      @coords[1] += y
      @matrix[@coords[0]][@coords[1]] = @nextint
      @nextint += 1
      if @nextint == @totalnums + 1
        print_matrix
        exit
      end
    end
  end
end

while 1:
  gridsize = ARGV[0].to_i
  x, y = rand(gridsize), rand(gridsize)
  it = SolveIt.new(x,y,gridsize)
  it.do_it
end
