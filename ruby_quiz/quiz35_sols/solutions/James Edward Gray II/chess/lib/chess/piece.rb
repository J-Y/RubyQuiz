#!/usr/local/bin/ruby -w

# piece.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	#
	# This class is the parent for all standard chess pieces.  It holds common
	# behavior for the pieces, allowing subclasses to override or add behavior
	# as needed.
	# 
	class Piece
		#
		# Create an instance of Piece.  This constructor is functional mainly
		# for inheritance purposes.  Generally, you'll want to create an
		# instance of a subclass, not Piece itself.
		# 
		def initialize( board, square, color )
			@board  = board
			@square = square
			@color  = color
			@moved  = false
		end
		
		# The square this piece is currently on.
		attr_reader :square
		# The color of this piece.
		attr_reader :color
		
		# 
		# This method is provided as a shorcut for fetching captures with an
		# instance variable.  It's actually just a shell over the class method
		# captures(board, square, color) which Piece does not implement.  
		# Subclasses are expected to provide this method which should return all
		# capturing moves currently available to the Piece.
		# 
		def captures(  )
			self.class.captures(@board, @square, @color)
		end

		# Just like captures(), but returns non-capturing moves only.
		def moves(  )
			self.class.moves(@board, @square, @color)
		end

		# Returns +true+ if this piece has moved yet in this game.
		def moved?(  )
			@moved
		end

		# Used to move the Piece to a new square.
		def square=( move_to )
			@square = move_to
			@moved  = true
		end
		
		# Pieces will only test equal if they are of the same class and color.
		def ==( other )
			self.class == other.class and @color == other.color
		end
		
		#
		# The String display for this piece.  This is the first letter of the
		# class name, capitalized for white or lowercase for black.
		# 
		def to_s(  )
			name = self.class.to_s[/\w+$/][0, 1]
			if @color == :white then name else name.downcase end
		end
	end
end
