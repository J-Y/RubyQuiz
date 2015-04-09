#!/usr/local/bin/ruby -w

# knight.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	# The container for the behavior of a standard chess knight.
	class Knight < Piece
		#
		# Returns all the capturing moves for a Knight on the provided _board_
		# at the provided _square_ of the provided _color_.
		# 
		def self.captures( board, square, color )
			Board.neighbors(square, :knight).reject do |sq|
				board[sq].nil? or board[sq].color == color
			end
		end

		#
		# Returns all the non-capturing moves for a Knight on the provided
		# _board_ at the provided _square_ of the provided _color_.
		# 
		def self.moves( board, square, color )
			Board.neighbors(square, :knight).select { |sq| board[sq].nil? }
		end
		
		# Overriding Piece's display with the standard "N" for a Knight.
		def to_s(  )
			if @color == :white then "N" else "n" end
		end
	end
end
