#!/usr/local/bin/ruby -w

# board.rb
#
#  Created by James Edward Gray II on 2005-06-13.
#  Copyright 2005 Gray Productions. All rights reserved.

# A namespace for chess objects.
module Chess
	#
	# A Board is a collection of chess pieces.  Board locations are always named
	# in "e4" style chess notation.  Board also includes methods for handling
	# chess geometry.
	# 
	class Board
		#
		# This method returns an Array of neighboring squares, by name.  It 
		# understands three different types of neighbors, based on the needs of 
		# standard chess pieces (specified in _looking_for_):
		# 
		# <tt>:king</tt>::    The Default.  Returns the eight immediate 
		#                     neighbors.
		# <tt>:knight</tt>::  Returns up to eight neighbors, all a knight's jump
		#                     away.
		# <tt>:pawn</tt>::    Returns the two neighbors that could be captured
		#                     by a pawn.
		# 
		def self.neighbors( square, looking_for = :king, color = :white )
			x = square[0] - ?a
			y = square[1, 1].to_i - 1
			neighbors = Array.new
			
			case looking_for
			when :king
				(-1..1).each do |x_off|
					(-1..1).each do |y_off|
						next if x_off == 0 and y_off == 0
						
						neighbors << "#{(x + x_off + ?a).chr}#{y + y_off + 1}"
					end
				end
			when :knight
				[-1, 1].each do |o_off|
					[-2, 2].each do |t_off|
						neighbors << "#{(x + o_off + ?a).chr}#{y + t_off + 1}"
						neighbors << "#{(x + t_off + ?a).chr}#{y + o_off + 1}"
					end
				end
			when :pawn
				if color == :white
					neighbors << "#{(x - 1 + ?a).chr}#{y + 1 + 1}"
					neighbors << "#{(x + 1 + ?a).chr}#{y + 1 + 1}"
				else
					neighbors << "#{(x - 1 + ?a).chr}#{y - 1 + 1}"
					neighbors << "#{(x + 1 + ?a).chr}#{y - 1 + 1}"
				end
			end

			neighbors.select { |sq| sq =~ /^[a-h][1-8]$/ }.sort
		end
		
		#
		# Create an instance of Board.  Internal state is set, and then setup()
		# is called to populate the board.
		# 
		def initialize(  )
			@squares    = Hash.new
			@turn       = :white
			@en_passant = nil
			
			setup
		end
		
		# The color of the current player.
		attr_reader :turn
		# The square that can be captured en-passant, this turn only.
		attr_reader :en_passant
		
		# Returns the piece at the provided square, or +nil+ if it's empty.
		def []( square_notation )
			@squares[square_notation]
		end
		
		# Returns a duplicate of the current board.
		def dup(  )
			Marshal.load(Marshal.dump(self))
		end
		
		include Enumerable
		
		#
		# Iteration support for Enumerable.  Blocks are yielded tuples with a 
		# square name, and then the contents of that square.
		# 
		def each(  )
			squares = ("a".."h").map do |file|
				(1..8).map { |rank| "#{file}#{rank}" }
			end.flatten.each do |square|
				yield [square, @squares[square]]
			end
		end

		#
		# If called with a square, this method will yield all the diagonals that
		# square is on.  Each diagonal will be given as two separate pieces, the
		# squares before the named square and those following.  The yielded 
		# Array of names is arranged so that the squares walk away from the 
		# named square.
		# 
		# If called without a square, all the diagonals of the board will be 
		# yielded.
		# 
		def each_diagonal( square = nil )
			if square
				file = square[0] - ?a
				rank = square[1, 1].to_i - 1
				[[-1, 1], [1, -1], [1, 1], [-1, -1]].each do |(x_off, y_off)|
					diag = Array.new
					x, y = file + x_off, rank + y_off
					while (0..7).include?(x) and (0..7).include?(y)
						name = "#{(x + ?a).chr}#{y + 1}"
						diag << [name, @squares[name]]
						x, y = x + x_off, y + y_off
					end
					yield diag unless diag.empty?
				end
			else
				# FIX ME!
			end
		end

		#
		# If called with a square, this method will yield all the files that
		# square is on.  Each file will be given as two separate pieces, the
		# squares before the named square and those following.  The yielded 
		# Array of names is arranged so that the squares walk away from the 
		# named square.
		# 
		# If called without a square, all the files of the board will be 
		# yielded.
		# 
		def each_file( square = nil )
			if square
				file = square[0, 1]
				rank = square[1, 1].to_i
				yield( (rank.succ..8).map do |r|
					name = "#{file}#{r}"
					[name, @squares[name]]
				end )
				yield( (1...rank).to_a.reverse.map do |r|
					name = "#{file}#{r}"
					[name, @squares[name]]
				end )
			else
				("a".."h").map do |file|
					yield( (1..8).map do |rank|
						name = "#{file}#{rank}"
						[name, @squares[name]]
					end )
				end
			end
		end
		
		#
		# If called with a square, this method will yield all the ranks that
		# square is on.  Each rank will be given as two separate pieces, the
		# squares before the named square and those following.  The yielded 
		# Array of names is arranged so that the squares walk away from the 
		# named square.
		# 
		# If called without a square, all the ranks of the board will be 
		# yielded.
		# 
		def each_rank( square = nil )
			if square
				file = square[0, 1]
				rank = square[1, 1]
				yield( (file.succ.."h").map do |f|
					name = "#{f}#{rank}"
					[name, @squares[name]]
				end )
				yield( ("a"...file).to_a.reverse.map do |f|
					name = "#{f}#{rank}"
					[name, @squares[name]]
				end )
			else
				(1..8).each do |rank|
					yield( ("a".."h").map do |file|
						name = "#{file}#{rank}"
						[name, @squares[name]]
					end )
				end
			end
		end
		
		#
		# Returns +true+ if the provided color's, or the default current 
		# player's, King is in check.
		# 
		def in_check?( who = @turn )
			king = find { |(s, pc)| pc and pc.color == who and pc.is_a? King }
			king.last.in_check?
		end

		#
		# Returns +true+ if the provided color's, or the default current 
		# player's, King is in checkmate.
		# 
		def in_checkmate?( who = @turn )
			king = find { |(s, pc)| pc and pc.color == who and pc.is_a? King }
			king.last.in_check? and moves.empty?
		end

		#
		# Returns +true+ if the provided color, or the default current player,
		# has no moves available.
		# 
		def in_stalemate?( who = @turn )
			moves(who).empty?
		end
		
		#
		# Moves a piece from _from_square_ to _to_square_.  If _promote_to_ is 
		# set to a class constant, the piece will be changed into that class
		# as it arrives.
		# 
		# This method is aware of castling, promotion and en-passant captures.
		# 
		# Before returning, this method advanced the turn indicator with a call
		# to next_turn().
		# 
		def move( from_square, to_square, promote_to = nil )
			@squares[to_square]   = @squares[from_square]
			@squares[from_square] = nil
		
			@squares[to_square].square = to_square

			# handle en-passant captures
			if @squares[to_square].is_a?(Pawn) and to_square == @en_passant
				@squares["#{to_square[0, 1]}#{from_square[1, 1]}"] = nil
			end
			# track last move for future en-passant captures
			if @squares[to_square].is_a?(Pawn) and
			   (from_square[1, 1].to_i - to_square[1, 1].to_i).abs == 2
				if from_square[1, 1] == "2"
					@en_passant = "#{from_square[0, 1]}3"
				else
					@en_passant = "#{from_square[0, 1]}6"
				end
			else
				@en_passant = nil
			end
			
			if @squares[to_square].is_a?(King) and       # queenside castles
			   from_square[0, 1] == "e" and to_square[0, 1] == "c"
				rank = to_square[1, 1]
				@squares["d#{rank}"] = @squares["a#{rank}"]
				@squares["a#{rank}"] = nil

				@squares["d#{rank}"].square = "d#{rank}"
			elsif @squares[to_square].is_a?(King) and    # kingside castles
			      from_square[0, 1] == "e" and to_square[0, 1] == "g"
				rank = to_square[1, 1]
				@squares["f#{rank}"] = @squares["h#{rank}"]
			 	@squares["h#{rank}"] = nil

				@squares["f#{rank}"].square = "f#{rank}"
			elsif not promote_to.nil?                    # pawn promotion
				@squares[to_square] = promote_to.new(self, to_square, @turn)
			end
			
			# advance the turn indicator
			next_turn
			
			self
		end

		#
		# Returns all legal moves for the current player, or provided color.  
		# Checks are considered in the building of this list.  Returns an Array
		# of tuples which have a starting square, followed by an Array of all
		# legal ending squares for that piece.
		# 
		def moves( who = @turn )
			moves = find_all { |(sq, pc)| pc and pc.color == who }.
			        map { |(sq, pc)| [sq, (pc.captures + pc.moves).sort] }
			moves.each do |(from, tos)|
				tos.delete_if { |to| dup.move(from, to).in_check?(who) }
			end
			moves.delete_if { |(from, tos)| tos.empty? }
			moves.sort
		end
		
		# This method is called to advance the turn of play.
		def next_turn(  )
			@turn = if @turn == :white then :black else :white end
		end
		
		#
		# This method is called to populate the board with the starting setup
		# for the game.
		# 
		def setup(  )
			("a".."h").each do |f|
				@squares["#{f}2"] = Chess::Pawn.new(self, "#{f}2", :white)
				@squares["#{f}7"] = Chess::Pawn.new(self, "#{f}7", :black)
			end
			["a", "h"].each do |f|
				@squares["#{f}1"] = Chess::Rook.new(self, "#{f}1", :white)
				@squares["#{f}8"] = Chess::Rook.new(self, "#{f}8", :black)
			end
			["b", "g"].each do |f|
				@squares["#{f}1"] = Chess::Knight.new(self, "#{f}1", :white)
				@squares["#{f}8"] = Chess::Knight.new(self, "#{f}8", :black)
			end
			["c", "f"].each do |f|
				@squares["#{f}1"] = Chess::Bishop.new(self, "#{f}1", :white)
				@squares["#{f}8"] = Chess::Bishop.new(self, "#{f}8", :black)
			end
			@squares["d1"] = Chess::Queen.new(self, "d1", :white)
			@squares["d8"] = Chess::Queen.new(self, "d8", :black)
			@squares["e1"] = Chess::King.new(self, "e1", :white)
			@squares["e8"] = Chess::King.new(self, "e8", :black)
		end
		
		#
		# This method is expected to draw the current position in ASCII art.  It
		# labels ranks and files and calls to_s() on the individual pieces to 
		# render them.
		# 
		def to_s(  )
			board = "  +#{'---+' * 8}\n"
			white = false
			(1..8).to_a.reverse.each do |rank|
				board << "#{rank} | "
				board << ("a".."h").map do |file|
					white = !white
					@squares["#{file}#{rank}"] || (white ? " " : ".")
				end.join(" | ")
				white = !white
				board << " |\n"
				board << "  +#{'---+' * 8}\n"
			end
			board << "    #{('a'..'h').to_a.join('   ')}\n"
			board
		end
	end
end
