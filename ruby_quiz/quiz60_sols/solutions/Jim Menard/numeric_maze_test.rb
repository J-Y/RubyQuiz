#! /usr/bin/env ruby

require 'test/unit'
require 'numeric_maze'

class NumericMazeTest < Test::Unit::TestCase
  def test_equal
    assert_equal("12 == 12. You tried to trick me!", solve(12, 12))
  end

  def test_prune_cycles
    paths = [[1,2,4,3,4], [1,2,3,4,5], [1,2,3,4,2], [1,2,3,4,1]]
    assert_equal([[1,2,3,4,5]], prune_cycles(paths))
  end

  def test_prune_longer_paths
    paths = [[1, 2, 3, 4, 5], [1, 2, 4, 5, 6]]
    assert_equal([[1, 2, 4, 5, 6]], prune_longer_paths(paths))

    paths = [[1, 2, 3], [1, 2, 4], [1, 4, 5]]
    assert_equal([[1, 2, 3], [1, 4, 5]], prune_longer_paths(paths))
  end

  def test_answers
    assert_equal([2, 1, 3, 5], solve(2, 5))

    solution = solve(5, 2)
    assert_equal(7, solution.length)
    assert_equal(2, solution.last)

    solution = solve(2, 9)
    assert_equal(6, solution.length)
    assert_equal(9, solution.last)

    solution = solve(9, 2)
    assert_equal(9, solution.length)
    assert_equal(2, solution.last)
  end

#   def test_longer_answer
#     assert_equal([22, 11, 13, 15, 30, 60, 62, 124, 248, 496, 498, 996,
#                    1992, 1994, 997, 999],
#                  solve(22, 999))
#   end
end
