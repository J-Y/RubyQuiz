#!/usr/local/bin/ruby -w

# bishop.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	# The container for the behavior of a standard chess bishop.
	class Bishop < Piece
		#
		# Returns all the capturing moves for a Bishop on the provided _board_
		# at the provided _square_ of the provided _color_.
		# 
		def self.captures( board, square, color )
			captures = Array.new
			board.each_diagonal(square) do |diagonal|
				diagonal.each do |(name, piece)|
					if piece
						captures << name if piece.color != color
						break
					end
				end
			end
			captures.sort
		end

		#
		# Returns all the non-capturing moves for a Bishop on the provided
		# _board_ at the provided _square_ of the provided _color_.
		# 
		def self.moves( board, square, color )
			moves = Array.new
			board.each_diagonal(square) do |diagonal|
				diagonal.each do |(name, piece)|
					if piece
						break
					else
						moves << name
					end
				end
			end
			moves.sort
		end
	end
end
