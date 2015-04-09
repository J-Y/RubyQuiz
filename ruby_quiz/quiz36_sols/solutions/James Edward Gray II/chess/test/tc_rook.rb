#!/usr/local/bin/ruby -w

# tc_rook.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestRook < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
		@board.move("h2", "h4")
		@board.move("g7", "g5")
		@board.move("h4", "g5")
		@board.move("e7", "e6")
		@board.move("h1", "h6")
		@board.move("a7", "a5")
	end

	def test_captures
		@board.each do |(square, piece)|
			case square
			when "h6"
				assert_equal(["e6", "h7"].sort, piece.captures)
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
			when "a8"
				assert_equal(%w{a7 a6}.sort, piece.moves)
			when "h6"
				assert_equal(%w{g6 f6 h5 h4 h3 h2 h1}.sort, piece.moves)
			else
				if piece and piece.is_a? Chess::Rook
					assert_equal([], piece.captures)
				end
			end
		end
	end
end
