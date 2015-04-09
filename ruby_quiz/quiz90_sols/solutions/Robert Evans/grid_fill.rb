class Grid
  SM = 3 # square move length
  DM = 2 # diagonal move length

  def initialize(size)
    @matrix = Array.new(size).map{Array.new(size)}
    @counter = 0
    @max = size * size
    @size = size
  end

  def solve
    no_moves_left = false
    pick_start_place
    while !no_moves_left && @counter < @max
      next_move = pick_move
      if next_move.nil?
        no_moves_left = true
      else
        move(next_move[0], next_move[1])
      end
    end

    puts no_moves_left ? "Out of moves :-(" : "Completed!"
    print_matrix unless @size > 30
  end

  def pick_start_place
    x = rand(@size)
    y = rand(@size)
    puts "starting at (#{x}, #{y})"
    move(x, y)
  end

  def pick_move
    moves = fast_available_moves
    if !moves.empty?
      moves.sort[0][1]
    else
      nil
    end
  end

  def move(x,y)
    @x = x
    @y = y
    # puts "moving to #{x},#{y}"
    @matrix[x][y] = @counter += 1
    # print_matrix
  end

  def available_moves
    [n(@x,@y), ne(@x,@y), e(@x,@y),
     se(@x,@y), s(@x,@y), sw(@x,@y),
     w(@x,@y), nw(@x,@y)].reject{ |ma| move_illegal?(ma) || !clear?(ma[0], ma[1]) }.map { |m| [count_moves(m), m] }
  end

  def fast_available_moves
    moves = []
    moves << [fast_count_moves([@x-SM, @y]), [@x-SM, @y]]  unless coord_illegal?(@x-SM) || !clear?(@x-SM, @y)
    moves << [fast_count_moves([@x-DM, @y+DM]), [@x-DM, @y+DM]] unless (coord_illegal?(@x-DM) || coord_illegal?(@y+DM)) || !clear?(@x-DM, @y+DM)
    moves << [fast_count_moves([@x, @y+SM]), [@x, @y+SM]] unless coord_illegal?(@y+SM) || !clear?(@x, @y+SM)
    moves << [fast_count_moves([@x+DM, @y+DM]), [@x+DM, @y+DM]] unless (coord_illegal?(@x+DM) || coord_illegal?(@y+DM)) || !clear?(@x+DM, @y+DM)
    moves << [fast_count_moves([@x+SM, @y]), [@x+SM, @y]] unless coord_illegal?(@x+SM) || !clear?(@x+SM, @y)
    moves << [fast_count_moves([@x+DM, @y-DM]), [@x+DM, @y-DM]] unless (coord_illegal?(@x+DM) || coord_illegal?(@y-DM)) || !clear?(@x+DM, @y-DM)
    moves << [fast_count_moves([@x, @y-SM]), [@x, @y-SM]] unless coord_illegal?(@y-SM) || !clear?(@x, @y-SM)
    moves << [fast_count_moves([@x-DM, @y-DM]), [@x-DM, @y-DM]] unless (coord_illegal?(@x-DM) || coord_illegal?(@y-DM)) || !clear?(@x-DM, @y-DM)
    moves
  end

  def n(x, y); [x - SM, y]; end

  def ne(x, y); [x - DM, y + DM]; end

  def e(x, y); [x, y + SM]; end

  def se(x, y); [x + DM, y + DM] ; end

  def s(x, y); [x + SM, y]; end

  def sw(x, y); [x + DM, y - DM] ; end

  def w(x, y); [x, y - SM]; end

  def nw(x, y); [x - DM, y - DM]; end

  def count_moves(m)
    x = m[0]
    y = m[1]
    [n(x, y), ne(x, y), e(x, y),
     se(x, y), s(x, y), sw(x, y),
     w(x, y), nw(x, y)].reject{ |ma| move_illegal?(ma) || !clear?(ma[0], ma[1])}.length
  end

  def fast_count_moves(m)
    x = m[0]
    y = m[1]
    count = 0
    count += 1 unless coord_illegal?(x-SM) || !clear?(x-SM, y)
    count += 1 unless (coord_illegal?(x-DM) || coord_illegal?(y+DM)) || !clear?(x-DM, y+DM)
    count += 1 unless coord_illegal?(y+SM) || !clear?(x, y+SM)
    count += 1 unless (coord_illegal?(x+DM) || coord_illegal?(y+DM)) || !clear?(x+DM, y+DM)
    count += 1 unless coord_illegal?(x+SM) || !clear?(x+SM, y)
    count += 1 unless (coord_illegal?(x+DM) || coord_illegal?(y-DM)) || !clear?(x+DM, y-DM)
    count += 1 unless coord_illegal?(y-SM) || !clear?(x, y-SM)
    count += 1 unless (coord_illegal?(x-DM) || coord_illegal?(y-DM)) || !clear?(x-DM, y-DM)
    count
  end

  def clear?(x,y)
    @matrix[x][y].nil?
  end

  def move_illegal?(m)
    x = m[0]
    y = m[1]
    x >= @size || x < 0 || y >= @size || y < 0
  end

  def coord_illegal?(n)
    n >= @size || n < 0
  end

  def print_matrix
    @matrix.each { |r|  r.each { |c| printf("%2d ", c)}; puts "\n"}
  end
end

def run(size=6)
  g = Grid.new(size)
  g.solve
  nil
end

if $0 == __FILE__
  run(ARGV[0].to_i)
end
