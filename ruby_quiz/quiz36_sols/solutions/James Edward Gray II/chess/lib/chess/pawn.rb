#!/usr/local/bin/ruby -w

# pawn.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	# The container for the behavior of a standard chess pawn.
	class Pawn < Piece
		#
		# Returns all the capturing moves for a Pawn on the provided _board_
		# at the provided _square_ of the provided _color_.  Includes en passant
		# captures.
		# 
		def self.captures( board, square, color )
			Board.neighbors(square, :pawn, color).reject do |sq|
				if board[sq].nil?
					square !~ /[45]$/ or board.en_passant != sq
				else
					board[sq].color == color
				end
			end
		end

		#
		# Returns all the non-capturing moves for a Pawn on the provided _board_
		# at the provided _square_ of the provided _color_.
		# 
		def self.moves( board, square, color )
			if color == :white
				forward     = square.sub(/\d/) { |rank| rank.to_i + 1 }
				two_forward = square.sub(/\d/) { |rank| rank.to_i + 2 }
			else
				forward     = square.sub(/\d/) { |rank| rank.to_i - 1 }
				two_forward = square.sub(/\d/) { |rank| rank.to_i - 2 }
			end

			if board[forward].nil?
				if ( (color == :white and square[1, 1] == "2") or
				     (color == :black and square[1, 1] == "7") ) and
				   board[two_forward].nil?
					[forward, two_forward].sort
				else
					[forward]
				end
			else
				Array.new
			end
		end
	end
end
