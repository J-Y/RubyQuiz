#!/usr/local/bin/ruby -w

# queen.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	#
	# The container for the behavior of a standard chess queen.  Queens are
	# simply treated as both a Bishop and a Rook.
	# 
	class Queen < Piece
		#
		# Returns all the capturing moves for a Queen on the provided _board_
		# at the provided _square_ of the provided _color_.
		# 
		def self.captures( board, square, color )
			captures = Rook.captures(board, square, color)
			captures += Bishop.captures(board, square, color)
			captures.sort
		end

		#
		# Returns all the non-capturing moves for a Queen on the provided
		# _board_ at the provided _square_ of the provided _color_.
		# 
		def self.moves( board, square, color )
			moves = Rook.moves(board, square, color)
			moves += Bishop.moves(board, square, color)
			moves.sort
		end
	end
end
