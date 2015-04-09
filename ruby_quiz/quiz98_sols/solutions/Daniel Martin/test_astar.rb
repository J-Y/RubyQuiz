require 'test/unit'
require 'astar'

class TC_Astar < Test::Unit::TestCase
  def setup
    @solver = Astar.new
  end

  def assert_paths_equal(expected,actual,message=nil)
    actual = actual.sub(/^(\s*\n)*/, '')
    expected = expected.sub(/^(\s*\n)*/, '')
    actual.sub!(/(\s*\n)*$/, '')
    actual.gsub!(/^\s*/m,'')
    actual.gsub!(/\s*$/m,'')
    expected.sub!(/(\s*\n)*$/, '')
    expected.gsub!(/^\s*/m,'')
    expected.gsub!(/\s*$/m,'')
    expected.scan(/\?/) {|x| expected[$~.begin(0)] = actual[$~.begin(0)]}
    assert_equal(expected,actual,message)
  end

  def test_simple_horizontal
    map = %q(@..X)
    solution = @solver.do_quiz_solution(map)
    assert_paths_equal(%q(####), solution)
  end

  def test_simple_vertical
    map = %q(@..X).split(//).join("\n")
    solution = @solver.do_quiz_solution(map)
    assert_paths_equal(%Q(#\n#\n#\n#), solution)
  end

  def test_quiz_statement
    map = %q(@*^^^
             ~~*~.
             **...
             ^..*~
             ~~*~X).sub(/ +/,'')
    solution = @solver.do_quiz_solution(map)
    assert_paths_equal(
       %q(##^^^
          ~~#~.
          **??.
          ^..#~
          ~~*~#), solution, "Didn't do test solution")
  end

  def test_bad_distance
    map = %q(@.*..
             ..~..
             ..^.X).sub(/ +/,'')
    solution = @solver.do_quiz_solution(map)
    assert_paths_equal(
          %q(#?#..
             .?~#.
             ..^.#), solution, "Got tripped up by manhattan distance")
  end
end
