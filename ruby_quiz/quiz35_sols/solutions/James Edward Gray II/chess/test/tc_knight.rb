#!/usr/local/bin/ruby -w

# tc_knight.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestKnight < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
		@board.move("e2", "e4")
		@board.move("g8", "f6")
	end

	def test_captures
		@board.each do |(square, piece)|
			case square
			when "f6"
				assert_equal(["e4"], piece.captures)
			else
				if piece and piece.is_a? Chess::Knight
					assert_equal([], piece.captures)
				end
			end
		end
	end
	
	def test_moves
		assert_equal(%w{a3 c3}.sort, @board["b1"].moves)
		assert_equal(%w{f3 h3 e2}.sort, @board["g1"].moves)
		assert_equal(%w{a6 c6}.sort, @board["b8"].moves)
		assert_equal(%w{g8 d5 h5 g4}.sort, @board["f6"].moves)
	end
end
