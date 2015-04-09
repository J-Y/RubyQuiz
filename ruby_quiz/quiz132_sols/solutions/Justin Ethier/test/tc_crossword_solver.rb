#
# Justin Ethier
# July 30th 2007
# 
# Unit Tests and Test Code for:
# Ruby Quiz 132: Crossword Solver
# http://www.rubyquiz.com/quiz132.html
# 
$:.unshift File.join(File.dirname(__FILE__), "..")
require 'test/unit'
require 'crossword_solver.rb'

class TestBoardLocation < Test::Unit::TestCase
  def test_loc
    loc = BoardLocation.new(10 * 4 + 1, 4)
    assert_equal(1, loc.col)
    assert_equal(10, loc.row)
  end
end

class TestCrosswordSolver < Test::Unit::TestCase
  def setup
    @template = [
      "_ _ _ _ _".split(" "),
      "_ # _ # _".split(" "),
      "_ _ _ _ _".split(" "),
      "_ # _ # _".split(" "),
      "_ _ _ _ _".split(" ")]
    @cb = CrosswordBoard.new(@template.flatten.join, 5)
    @c = CrosswordSolver.new(@cb)
  end
  
  def test_basic_board_operations
    @cb.add("abcde", 0, 0, :vert)
    assert_equal("a____", @cb.get_contents(0, 0, :horz, 5))
    assert_equal("abcde", @cb.get_contents(0, 0, :vert, 5))
            
    @cb.add("abcde", 0, 0, :horz)
    assert_equal("abcde", @cb.get_contents(0, 0, :horz, 5))
    assert_equal("abcde", @cb.get_contents(0, 0, :vert, 5))
    
    @cb.remove("abcde", 0, 0, :horz)
    @cb.remove("abcde", 0, 0, :horz)    
    assert_equal("a____", @cb.get_contents(0, 0, :horz, 5))
    assert_equal("abcde", @cb.get_contents(0, 0, :vert, 5))

    @cb.remove("abcde", 0, 0, :vert)
    assert_equal("_____", @cb.get_contents(0, 0, :horz, 5))
    assert_equal("_____", @cb.get_contents(0, 0, :vert, 5))
    
    @cb.print  
  end
  
  def test_next_free_space
    words = ["rests", "rinds", "ekiwu", "stees", "niece", "susan"]
    row, col, orient, length = @c.find_next_free_space  
    assert_equal(0, row)
    assert_equal(0, col)
    assert_equal(:horz, orient)    
    assert_equal(5, length)
    @cb.add(words[1], row, col, orient)

    row, col, orient, length = @c.find_next_free_space  
    assert_equal(0, row)
    assert_equal(0, col)
    assert_equal(:vert, orient)    
    assert_equal(5, length)
    @cb.add(words[1], row, col, orient)
  end

  def test_solve_hardcoded
    puts "test_solve_hardcoded"
    words = ["rests", "rinds", "skews", "steen", "niece", "susan"]
    for i in 0..words.size - 1
      row, col, orient, length = @c.find_next_free_space
      @cb.add(words[i], row, col, orient)
    end
    @cb.print  
  end
  
  def test_solve
    puts "test_solve"
    words = ["rests", "rinds", "skews", "steen", "niece", "susan"].reverse
    @c.solve(words)
    @cb.print
  end
  
  def test_solve_file
    puts "test_solve_file"
    dict = CrosswordSolver.read_dictionary_from_file('linux.words.txt') #linux.words.a.txt
    #dict = CrosswordSolver.read_dictionary_from_file('test_dict.txt')

    cb = CrosswordSolver.read_template_from_file('test_board.txt')
    
    @c = CrosswordSolver.new(cb)
    @c.solve(dict)
    cb.print   

    puts "test_solve_file - Partially filled puzzle"
    cb = CrosswordSolver.read_template_from_file('test_partial_board.txt')
    @c = CrosswordSolver.new(cb)
    @c.solve(dict)
    cb.print    
  end
end
