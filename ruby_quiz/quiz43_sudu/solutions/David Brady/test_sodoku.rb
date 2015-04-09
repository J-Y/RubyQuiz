#!/usr/bin/env ruby

require 'sodoku'
require 'test/unit'

class TestSodoku < Test::Unit::TestCase
  def setup
    @board_strings = ["+-------+-------+-------+
| _ 6 _ | 1 _ 4 | _ 5 _ |
| _ _ 8 | 3 _ 5 | 6 _ _ |
| 2 _ _ | _ _ _ | _ _ 1 |
+-------+-------+-------+
| 8 _ _ | 4 _ 7 | _ _ 6 |
| _ _ 6 | _ _ _ | 3 _ _ |
| 7 _ _ | 9 _ 1 | _ _ 4 |
+-------+-------+-------+
| 5 _ _ | _ _ _ | _ _ 2 |
| _ _ 7 | 2 _ 6 | 9 _ _ |
| _ 4 _ | 5 _ 8 | _ 7 _ |
+-------+-------+-------+
",
"+-------+-------+-------+
| _ _ 2 | _ _ 5 | _ 7 9 |
| 1 _ 5 | _ _ 3 | _ _ _ |
| _ _ _ | _ _ _ | 6 _ _ |
+-------+-------+-------+
| _ 1 _ | 4 _ _ | 9 _ _ |
| _ 9 _ | _ _ _ | _ 8 _ |
| _ _ 4 | _ _ 9 | _ 1 _ |
+-------+-------+-------+
| _ _ 9 | _ _ _ | _ _ _ |
| _ _ _ | 1 _ _ | 3 _ 6 |
| 6 8 _ | 3 _ _ | 4 _ _ |
+-------+-------+-------+
",
"+-------+-------+-------+
| _ _ 1 | _ 2 _ | 8 _ _ |
| _ 7 _ | 3 1 _ | _ 9 _ |
| 3 _ _ | _ 4 5 | _ _ 7 |
+-------+-------+-------+
| _ 9 _ | 7 _ _ | 5 _ _ |
| _ 4 2 | _ 5 _ | 1 3 _ |
| _ _ 3 | _ _ 9 | _ 4 _ |
+-------+-------+-------+
| 2 _ _ | 5 7 _ | _ _ 4 |
| _ 3 _ | _ 9 1 | _ 6 _ |
| _ _ 4 | _ _ _ | 3 _ _ |
+-------+-------+-------+
",
"+-------+-------+-------+
| _ _ _ | _ _ _ | _ _ _ |
| _ _ _ | _ _ _ | _ _ _ |
| _ _ _ | _ _ _ | _ _ _ |
+-------+-------+-------+
| _ _ _ | _ _ _ | _ _ _ |
| _ _ _ | _ _ _ | _ _ _ |
| _ _ _ | _ _ _ | _ _ _ |
+-------+-------+-------+
| _ _ _ | _ _ _ | _ _ _ |
| _ _ _ | _ _ _ | _ _ _ |
| _ _ _ | _ _ _ | _ _ _ |
+-------+-------+-------+
"]

    @board_arrays = [
      [
        [0,6,0,1,0,4,0,5,0],
        [0,0,8,3,0,5,6,0,0],
        [2,0,0,0,0,0,0,0,1],
        [8,0,0,4,0,7,0,0,6],
        [0,0,6,0,0,0,3,0,0],
        [7,0,0,9,0,1,0,0,4],
        [5,0,0,0,0,0,0,0,2],
        [0,0,7,2,0,6,9,0,0],
        [0,4,0,5,0,8,0,7,0]]
    ]

    @board_row_values1 = [2,3,7,8,9]
    @board_col_values1 = [1,3,4,6,9]
    @board_xy_values1 = [3,9]
    @pinch1 = [5,2]
    @pinch1_values = [9]
    @boards = []
    @board_strings.each do |board_string|
      @boards.push(Sodoku.new(board_string))
    end
    @b1 = Sodoku.new @board_strings[0]
  end

  def test_unittester
    assert(true, 'Erk, assert(true) failed!')
  end

  def test_load
    b = Sodoku.new
    b.load @board_strings[0]
    assert_equal @board_arrays[0], b.board
  end

  def test_string_ctor
    assert_equal @board_arrays[0], @b1.board
  end

  def test_copy_ctor
    assert_equal @board_arrays[0], Sodoku.new(@b1).board
  end

  def test_copy_ctor_doesnt_alias
    b2 = Sodoku.new(@b1)
    assert_equal(@b1.board, b2.board)
    b2.board[0][0] = '9'
    assert_not_equal b2.board[0][0], @b1.board[0][0], "After copying @b1, changes to b2 should not affect @b1."
  end

  def test_invalid_board1
    @b1.board[3].shift
    assert @b1.board[3].length == 8, "@b1.board[3] should be length 8, but is #{@b1.board[3].length}"
    assert !@b1.valid?, "@b1 should not be valid after dropping a cell from row 3."
  end

  def test_invalid_board2
    @b1.board.shift
    assert @b1.board.length == 8, "@b1.board should be length 8, but is #{@b1.board.length}"
    assert !@b1.valid?, "@b1 should not be valid after dropping a row."
  end

  def test_invalid_board_dup
    @b1.board[0][0] = 6
    assert !@b1.valid?, "@b1 should not be valid with [0,0] and [0,1] being duplicate."
    @b1.board[0][0] = 0
    assert @b1.valid?, "@b1 should be valid."
    @b1.board[0][0] = 2
    assert !@b1.valid?, "@b1 should not be valid with [0,0] and [2,0] being duplicate."
  end

  def test_set
    @b1.set(0,0,3)
    assert_equal 3, @b1.board[0][0]
  end

  def test_possible_col_values
    v = @b1.possible_col_values(0)
    assert_equal(@board_col_values1, v)
  end

  def test_possible_row_values
    v = @b1.possible_row_values(0)
    assert_equal(@board_row_values1, v)
  end
  
  def test_possible_block_values
# +-------+-------+-------+
# | _ 6 _ | 1 _ 4 | _ 5 _ |
# | _ _ 8 | 3 _ 5 | 6 _ _ |
# | 2 _ _ | _ _ _ | _ _ 1 |
# +-------+-------+-------+
# | 8 _ _ | 4 _ 7 | _ _ 6 |
# | _ _ 6 | _ _ _ | 3 _ _ |
# | 7 _ _ | 9 _ 1 | _ _ 4 |
# +-------+-------+-------+
# | 5 _ _ | _ _ _ | _ _ 2 |
# | _ _ 7 | 2 _ 6 | 9 _ _ |
# | _ 4 _ | 5 _ 8 | _ 7 _ |
# +-------+-------+-------+    
    cv = [
      [ [1,3,4,5,7,9], [2,6,7,8,9], [2,3,4,7,8,9] ],
      [ [1,2,3,4,5,9], [2,3,5,6,8], [1,2,5,7,8,9] ],
      [ [1,2,3,6,8,9], [1,3,4,7,9], [1,3,4,5,6,8] ]
    ]
    9.times do |y|
      8.times do |x|
        if @b1.board[y][x].zero?
          cvx = x / 3
          cvy = y / 3
          v = @b1.possible_block_values(x,y)
          assert v.sort == cv[cvy][cvx], "Possible cell values for (#{x},#{y}) are wrong."
          end
      end
    end
  end

  def test_possible_values
    assert_equal(@board_xy_values1, @b1.possible_values(0,0))
    @b1.set(0,8,3)
    @board_xy_values1 -= [3]
    assert_equal(@board_xy_values1, @b1.possible_values(0,0))
    @b1.set(0,6,9)
    assert_nil @b1.possible_values(0,0)
  end    

  def test_unsolvable
    assert !@b1.unsolvable?, "@b1 is solvable, but @b1.unsolvable? returned true."
    @b1.set(0,8,3)
    assert @b1.unsolvable?, "@b1 is not solvable because [0,0] has no solutions, but @b1.unsolvable? returned false."
  end

  def test_find_pinch
    p = @b1.find_pinch
    pvtest = @b1.possible_values(p[0], p[1])
    pvref =  @b1.possible_values(@pinch1[0], @pinch1[1])
    assert_equal(@pinch1, p, "Pinch options at @pinch1: (#{pvref.join(', ')}), at found: (#{pvtest.join(', ')})")
  end

  def test_solved
    # KWM!
  end

  def test_to_s
    assert_equal @board_strings[0], @b1.to_s
  end

  def test_settle
    # putting 3,4 in (0,1), (0,2) is enough to settle all of column 0
    @b1.set(0,0,3)
    @b1.set(0,1,4)
    @b1.settle

    assert_equal 3, @b1.board[0][0], "@b1.settle should have set (0,0) to 3."
    assert_equal 4, @b1.board[1][0], "@b1.settle should have set (1,0) to 4."
    assert_equal 2, @b1.board[2][0], "@b1.settle should have set (2,0) to 2."
    assert_equal 8, @b1.board[3][0], "@b1.settle should have set (3,0) to 8."
    assert_equal 9, @b1.board[4][0], "@b1.settle should have set (4,0) to 9."
    assert_equal 7, @b1.board[5][0], "@b1.settle should have set (5,0) to 7."
    assert_equal 5, @b1.board[6][0], "@b1.settle should have set (6,0) to 5."
    assert_equal 1, @b1.board[7][0], "@b1.settle should have set (7,0) to 1."
    assert_equal 6, @b1.board[8][0], "@b1.settle should have set (8,0) to 6."
  end

  def test_solution_valid
    @boards.each_with_index do |board, i|
      solution = board.solution
      if !solution.nil?
        assert solution.valid?, "board #{i} returned a solution that is not valid."
      end
    end
  end
end
