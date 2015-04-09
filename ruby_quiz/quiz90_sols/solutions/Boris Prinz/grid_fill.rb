### pnp.rb
class PenAndPaper
  def initialize(width)
    @width = width
  end

  def each_neighbour(pos)
    w = @width
    x = pos % w
    y = pos / w
    # north
    yield(pos - 3*w)     if y > 2
    # north east
    yield(pos - 2*w + 2) if y > 1 and x < w - 2
    # east
    yield(pos + 3)       if x < w - 3
    # south east
    yield(pos + 2*w + 2) if y < w - 2 and x < w - 2
    # south
    yield(pos + 3*w)     if y < w - 3
    # south west
    yield(pos + 2*w - 2) if y < w - 2 and x > 1
    # west
    yield(pos - 3)       if x > 2
    # north west
    yield(pos - 2*w - 2) if y > 1 and x > 1
  end

  def solve(pos=0)
    board = []
    board[pos] = 1
    @board = solve_board(board, pos, 2)
  end

  def solve_board(board, pos, ind)
    return board if ind > @width*@width
    each_neighbour(pos) do |n|
      next if board[n] # position already taken?
      f = board.dup
      f[n] = ind
      f2 = solve_board(f, n, ind + 1)
      return f2 if f2
    end
    nil # no more positions
  end

  def to_s
    s = ''
    (0...@width).each do |y|
      (0...@width).each do |x|
        s += "%3d " % @board[y*@width+x]
      end
      s += "\n"
    end
    s
  end
end



### test_pnp.rb
require 'test/unit'
require 'pnp'

class PenAndPaperTest < Test::Unit::TestCase
  def neighbours_of(pos)
    neighbours = []
    pnp = PenAndPaper.new(5)
    pnp.each_neighbour(pos) {|i| neighbours << i}
    neighbours
  end

  def test_neighbours
    assert_equal [ 3, 12, 15], neighbours_of(0)
    assert_equal [14, 17, 10], neighbours_of(2)
    assert_equal [18, 11,  0], neighbours_of(3)
    assert_equal [22, 11,  2], neighbours_of(14)
    assert_equal [ 2,  9,  5], neighbours_of(17)
    assert_equal [ 5, 12, 23], neighbours_of(20)
    assert_equal [ 9, 21, 12], neighbours_of(24)
  end

  def test_solve
    pnp = PenAndPaper.new(5)
    pnp.solve(0)
    assert_equal <<END, pnp.to_s
  1  22  12   2   7
19  25   5  20  10
13  16   8  23  15
  4  21  11   3   6
18  24  14  17   9
END
  end
end
