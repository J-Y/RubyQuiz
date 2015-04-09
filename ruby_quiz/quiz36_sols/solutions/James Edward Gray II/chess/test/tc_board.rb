#!/usr/local/bin/ruby -w

# tc_board.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "chess"

class TestBoard < Test::Unit::TestCase
	def setup
		@board = Chess::Board.new
	end
	
	def test_neighbors
		assert_equal( %w{d5 e5 f5 d4 f4 d3 e3 f3}.sort,
		              Chess::Board.neighbors("e4") )
		assert_equal( %w{d6 f6 c5 g5 c3 g3 d2 f2}.sort,
		              Chess::Board.neighbors("e4", :knight) )
		assert_equal(%w{d5 f5}.sort, Chess::Board.neighbors("e4", :pawn))
		assert_equal( %w{d3 f3}.sort,
		              Chess::Board.neighbors("e4", :pawn, :black) )
		
		assert_equal(%w{a2 b2 b1}.sort, Chess::Board.neighbors("a1"))
		assert_equal( %w{g8 f7 f5 g4}.sort,
		              Chess::Board.neighbors("h6", :knight) )
	end
	
	def test_indexing
		assert_equal(Chess::King.new(nil, nil, :white), @board["e1"])
		assert_equal(Chess::Queen.new(nil, nil, :black), @board["d8"])
	end
	
	def test_display
		assert_equal( "  +---+---+---+---+---+---+---+---+\n" +
		              "8 | r | n | b | q | k | b | n | r |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "7 | p | p | p | p | p | p | p | p |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "6 |   | . |   | . |   | . |   | . |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "5 | . |   | . |   | . |   | . |   |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "4 |   | . |   | . |   | . |   | . |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "3 | . |   | . |   | . |   | . |   |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "2 | P | P | P | P | P | P | P | P |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "1 | R | N | B | Q | K | B | N | R |\n" +
		              "  +---+---+---+---+---+---+---+---+\n" +
		              "    a   b   c   d   e   f   g   h\n", @board.to_s )
	end
	
	def test_turn
		assert_equal(:white, @board.turn)
		@board.move("e2", "e4")
		assert_equal(:black, @board.turn)
	end
	
	def test_en_passant
		@board.move("e2", "e4")
		assert_equal("e3", @board.en_passant)
	end
	
	def test_duplication
		assert_not_nil(copy = @board.dup)
		assert_instance_of(Chess::Board, copy)
		
		@board.move("e2", "e4")
		assert_nil(copy["e4"])
		assert_nil(@board["e2"])
	end
	
	def test_each
		squares = ("a".."h").map { |f| (1..8).map { |r| "#{f}#{r}" } }.flatten
		@board.each do |(square, piece)|
			assert_equal(squares.shift, square)
			assert_not_nil(piece) if square =~ /[1278]$/
		end
	end
	
	def test_enumerable
		square, piece = @board.find do |(sq, pc)|
			pc == Chess::King.new(nil, nil, :white)
		end
		assert_equal("e1", square)
	end
	
	def test_each_diagonal
		diagonals = [%w{b7 c6 d5 e4 f3 g2 h1}]
		@board.each_diagonal("a8") do |diagonal|
			test = diagonals.shift
			diagonal.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[127]$/
			end
		end
		diagonals = [%w{d5 c6 b7 a8}, %w{f3 g2 h1}, %w{f5 g6 h7}, %w{d3 c2 b1}]
		@board.each_diagonal("e4") do |diagonal|
			test = diagonals.shift
			diagonal.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end
	end
	
	def test_each_file
		files = [%w{a2 a3 a4 a5 a6 a7 a8}]
		@board.each_file("a1") do |file|
			test = files.shift
			file.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end
		files = [%w{d6 d7 d8}, %w{d4 d3 d2 d1}]
		@board.each_file("d5") do |file|
			test = files.shift
			file.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end

		files = ("a".."h").map { |f| (1..8).map { |r| "#{f}#{r}" } }
		@board.each_file do |file|
			test = files.shift
			file.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end
	end

	def test_each_rank
		ranks = [%w{b1 c1 d1 e1 f1 g1 h1}]
		@board.each_rank("a1") do |rank|
			test = ranks.shift
			rank.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end
		ranks = [%w{e5 f5 g5 h5}, %w{c5 b5 a5}]
		@board.each_rank("d5") do |rank|
			test = ranks.shift
			rank.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end

		ranks = (1..8).map { |r| ("a".."h").map { |f| "#{f}#{r}" } }
		@board.each_rank do |rank|
			test = ranks.shift
			rank.each do |(square, piece)|
				assert_equal(test.shift, square)
				assert_not_nil(piece) if square =~ /[1278]$/
			end
		end
	end
	
	def test_game_status
		@board.move("e2", "e4")
		@board.move("e7", "e5")
		@board.move("f1", "c4")
		@board.move("b8", "c6")
		@board.move("d1", "f3")
		@board.move("d7", "d6")
		@board.move("f3", "f7")
		assert(@board.in_checkmate?)
		assert_not_equal(@board.turn, @board.next_turn)
		assert(!@board.in_checkmate?)
		
		@board = Chess::Board.new
		@board.move("e2", "e4")
		@board.move("f7", "f5")
		@board.move("d1", "h5")
		assert(@board.in_check?)
		assert_not_equal(@board.turn, @board.next_turn)
		assert(!@board.in_check?)
		
		@board = Chess::Board.new
		@board.instance_eval do
			@squares       = Hash.new
			
			@squares["h1"] = Chess::King.new(self, "h1", :white)

			@squares["g8"] = Chess::Rook.new(self, "g8", :black)
			@squares["a2"] = Chess::Rook.new(self, "a2", :black)
			@squares["a1"] = Chess::King.new(self, "a1", :black)
		end
		assert(@board.in_stalemate?)
		assert_not_equal(@board.turn, @board.next_turn)
		assert(!@board.in_stalemate?)
	end
	
	def test_moves
		assert_equal(10, @board.moves.size)
		
		king_pawn = @board["e2"]
		assert_same(@board, @board.move("e2", "e4"))
		assert_equal(king_pawn, @board["e4"])
		assert_nil(@board["e2"])
		
		@board.move("e7", "e6")
		@board.move("e4", "e5", Chess::Queen)
		assert_not_equal(king_pawn, @board["e5"])
		assert_instance_of(Chess::Queen, @board["e5"])
		assert_equal(:white, @board["e5"].color)
		assert_nil(@board["e4"])
	end
	
	def test_setup
		starting_board = @board.to_s
		@board.move("e2", "e4")
		@board.move("e7", "e5")
		@board.move("f1", "c4")
		@board.move("b8", "c6")
		@board.move("d1", "f3")
		@board.move("d7", "d6")
		@board.move("f3", "f7")
		assert_not_equal(starting_board, @board.to_s)
		@board.instance_eval do
			@squares = Hash.new
			setup
		end
		assert_equal(starting_board, @board.to_s)
	end
end
