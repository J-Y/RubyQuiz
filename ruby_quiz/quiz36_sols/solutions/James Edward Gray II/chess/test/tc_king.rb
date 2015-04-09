#!/usr/local/bin/ruby -w

# tc_king.rb
#
#  Created by James Edward Gray II on 2005-06-14.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestKing < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
		@board.move("e2", "e4")
		@board.move("e7", "e5")
		@board.move("d1", "f3")
		@board.move("b8", "c6")
		@board.move("f3", "f7")
	end
	
	def test_check
		assert(@board["e8"].in_check?)
		assert(!@board["e1"].in_check?)
	end
	
	def test_captures
		assert_equal(["f7"], @board["e8"].captures)
		assert_equal([], @board["e1"].captures)
	end

	def test_moves
		assert_equal([], @board["e8"].moves)
		assert_equal(["d1", "e2"].sort, @board["e1"].moves)
	end

	def test_castle
		board = Chess::Board.new
		board.move("e2", "e4")
		board.move("e7", "e5")
		board.move("f1", "c4")
		board.move("b8", "c6")
		board.move("g1", "f3")
		
		assert(%w{e2 f1 g1}.sort, board["e8"].moves)
	end
end
