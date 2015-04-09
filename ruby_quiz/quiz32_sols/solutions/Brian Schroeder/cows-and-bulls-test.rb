# Tests for cows and bulls classes
#
# (c) 2005 Brian Schröder
# http://ruby.brian-schroeder.de/quiz/cows-and-bulls/
#
# This code is published under the GPL. 
# See http://www.gnu.org/copyleft/gpl.html for more information

require 'test/unit'
require 'cows-and-bulls'

class TC_CowsAndBulls < Test::Unit::TestCase
  def setup
    @g = CowsAndBullsGame.new('cow')
  end
  
  def test_cows_and_bulls_count
    @g.guess = 'cow'
    assert_equal([0, 3], @g.cows_and_bulls, "All equal")
    @g.guess = 'cog'
    assert_equal([0, 2], @g.cows_and_bulls)
    @g.guess = 'cgg'
    assert_equal([0, 1], @g.cows_and_bulls)
    @g.guess = 'ggc'
    assert_equal([1, 0], @g.cows_and_bulls)
    @g.guess = 'owc'
    assert_equal([3, 0], @g.cows_and_bulls)
    @g.guess = 'lcc'
    assert_equal([1, 0], @g.cows_and_bulls)
  end

  def test_correct
    assert(!@g.correct)
    @g.guess = 'car'
    assert(!@g.correct)
    @g.guess = 'cow'
    assert(@g.correct)
  end

  def test_word_length
    assert_equal(3, @g.word_length)
  end
end
