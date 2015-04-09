#!/usr/local/bin/ruby -w

# tc_queen.rb
#
#  Created by James Edward Gray II on 2005-06-14.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestQueen < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
		@board.move("e2", "e4")
		@board.move("e7", "e5")
		@board.move("d1", "h5")
	end

	def test_captures
		assert_equal(%w{f7 h7 e5}.sort, @board["h5"].captures)
		assert_equal([], @board["d8"].captures)
	end

	def test_moves
		assert_equal(%w{g6 h6 h4 h3 g4 f3 e2 d1 g5 f5}.sort, @board["h5"].moves)
		assert_equal(%w{e7 f6 g5 h4}.sort, @board["d8"].moves)
	end
end
