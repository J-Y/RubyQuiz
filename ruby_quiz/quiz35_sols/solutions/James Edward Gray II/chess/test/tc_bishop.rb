#!/usr/local/bin/ruby -w

# tc_bishop.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestBishop < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
		@board.move("e2", "e4")
		@board.move("g7", "g6")
		@board.move("f1", "c4")
		@board.move("f8", "g7")
	end

	def test_captures
		@board.each do |(square, piece)|
			case square
			when "c4"
				assert_equal(["f7"], piece.captures)
			when "g7"
				assert_equal(["b2"], piece.captures)
			else
				if piece and piece.is_a? Chess::Rook
					assert_equal([], piece.captures)
				end
			end
		end
	end

	def test_moves
		@board.each do |(square, piece)|
			case square
			when "c4"
				assert_equal(%w{b5 a6 d5 e6 d3 e2 f1 b3}.sort, piece.moves)
			when "g7"
				assert_equal(%w{f8 f6 e5 d4 c3 h6}.sort, piece.moves)
			else
				if piece and piece.is_a? Chess::Rook
					assert_equal([], piece.moves)
				end
			end
		end
	end
end
