#!/usr/local/bin/ruby -w

require "test/unit"

require "cowsnbulls"

class TestLibrary < Test::Unit::TestCase
	def setup
		@cow  = WordGame.new(3)
		@moon = WordGame.new(4)
	end
	
	def test_cows
		assert_equal([3, 0], @moon.guess("onto"))
		assert_equal([1, 1], @moon.guess("some"))
		assert_equal([2, 2], @moon.guess("mono"))
	end
	
	def test_bulls
		assert_equal([0, 1], @cow.guess("cab"))
		assert_equal([0, 1], @cow.guess("cat"))
		assert_equal([0, 2], @cow.guess("cot"))
	end
	
	def test_final_guesses
		assert_equal(true, @cow.guess("cow"))
		assert_equal(true, @moon.guess("moon"))
	end
end
