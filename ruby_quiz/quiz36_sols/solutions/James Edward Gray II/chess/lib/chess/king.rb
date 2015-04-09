#!/usr/local/bin/ruby -w

# king.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	# The container for the behavior of a standard chess king.
	class King < Piece
		#
		# Returns all the capturing moves for a King on the provided _board_
		# at the provided _square_ of the provided _color_.  Moves into check
		# are filtered from the list.
		# 
		def self.captures( board, square, color )
			Board.neighbors(square).reject do |sq|
				board[sq].nil? or board[sq].color == color or
				in_check?(board, sq, color)
			end
		end

		#
		# Returns all the non-capturing moves for a King on the provided _board_
		# at the provided _square_ of the provided _color_.  Moves into check
		# are filtered from the list.  Castling moves are added, if the 
		# conditions are met, as two-square King moves.
		# 
		def self.moves( board, square, color )
			moves = Board.neighbors(square).select do |sq|
				board[sq].nil? and not in_check?(board, sq, color)
			end
			
			# handle castling
			unless in_check?(board, square, color)
				king = board[square]
				if king and king.is_a?(King) and not king.moved?
					rank = square[1, 1].to_i
					rook = board["h#{rank}"]
					if rook and rook.is_a?(Rook) and not rook.moved?
						if board["f#{rank}"].nil? and
						   not in_check?(board, "f#{rank}", color) and
						   board["g#{rank}"].nil? and
						   not in_check?(board, "g#{rank}", color)
							moves << "g#{rank}"
						end
					end

					rook = board["a#{rank}"]
					if rook and rook.is_a?(Rook) and not rook.moved?
						if board["d#{rank}"].nil? and
						   not in_check?(board, "d#{rank}", color) and
						   board["c#{rank}"].nil? and
						   not in_check?(board, "c#{rank}", color) and
						   board["b#{rank}"].nil? and
						   not in_check?(board, "b#{rank}", color)
							moves << "c#{rank}"
						end
					end
				end
			end
			
			moves.sort
		end

		#
		# Returns true if the given _square_ on the given _board_ is in check, 
		# for the given _color_.
		# 
		# This method is in King, because it is standard chess behavior for a 
		# King, but note that it does not assume it's finding the answer for a 
		# King.  This method generally finds squares of control and can be 
		# useful in many areas of chess.
		# 
		def self.in_check?( board, square, color )
			return true if Board.neighbors(square).any? do |name|
				piece = board[name]
				piece and piece.color != color and piece.is_a?(King)
			end
			
			return true if Rook.captures(board, square, color).any? do |name|
				board[name].is_a?(Rook) or board[name].is_a?(Queen)
			end
			return true if Bishop.captures(board, square, color).any? do |name|
				board[name].is_a?(Bishop) or board[name].is_a?(Queen)
			end
			return true if Knight.captures(board, square, color).any? do |name|
				board[name].is_a?(Knight)
			end
			return true if Pawn.captures(board, square, color).any? do |name|
				board[name].is_a?(Pawn)
			end
			
			false
		end
		
		# A shortcut to the class method of the same name using an instance.
		def in_check?(  )
			self.class.in_check?(@board, @square, @color)
		end
	end
end
