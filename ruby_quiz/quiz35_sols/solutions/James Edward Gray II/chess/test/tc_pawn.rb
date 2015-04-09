#!/usr/local/bin/ruby -w

# tc_pawn.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestPawn < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
		@board.move("e2", "e4")
		@board.move("d7", "d5")
		@board.move("c2", "c4")
	end
	
	def test_captures
		@board.each do |(square, piece)|
			case square
			when "e4", "c4"
				assert_equal(["d5"], piece.captures)
			when "d5"
				assert_equal(["c4", "e4"].sort, piece.captures)
			else
				if piece and piece.is_a? Chess::Pawn
					assert_equal([], piece.captures)
				end
			end
		end
	end

	def test_moves
		@board.move("e7", "e5")
		
		@board.each do |(square, piece)|
			case square
			when "c4"
				assert_equal(["c5"], piece.moves)
			when "e4", "e5"
				assert_equal([], piece.moves)
			when "d5"
				assert_equal(["d4"], piece.moves)
			else
				if piece and piece.color == :white and piece.is_a? Chess::Pawn
					assert_equal( [ piece.square.sub(/\d/) { |r| r.to_i + 1 },
					                piece.square.sub(/\d/) { |r| r.to_i + 2 } 
					                ].sort, piece.moves )
				elsif piece and piece.color == :black and
				      piece.is_a? Chess::Pawn
					assert_equal( [ piece.square.sub(/\d/) { |r| r.to_i - 1 },
					                piece.square.sub(/\d/) { |r| r.to_i - 2 } 
					                ].sort, piece.moves )
				end
			end
		end
	end
	
	def test_en_passant
		@board.move("f2", "f4")
		@board.move("a7", "a6")
		@board.move("f4", "f5")
		@board.move("g7", "g5")

		@board.each do |(square, piece)|
			case square
			when "e4", "c4"
				assert_equal(["d5"], piece.captures)
			when "d5"
				assert_equal(["c4", "e4"].sort, piece.captures)
			when "f5"
				assert_equal(["g6"], piece.captures)
			else
				if piece and piece.is_a? Chess::Pawn
					assert_equal([], piece.captures)
				end
			end
		end
	end
end
