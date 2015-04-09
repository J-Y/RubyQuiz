module GKChess
	class Piece
		WHITE = :White
		BLACK = :Black

		OTHER_COLOR = { WHITE => BLACK, BLACK => WHITE }

		attr_reader :board, :color, :col, :row

		def initialize ( board, color )
			@board = board
			@moved = false
			@color = color
		end

		def moved?
			@moved
		end

		def in_play?
			@col && @row
		end
		
		def position=( colrow )
			dest_col, dest_row = colrow.to_s.split( '' )
			@moved = @col && @row
			@col = dest_col
			@row = dest_row
			@col + @row
		end
		
		def captured!
			@row = @col = nil
		end
	
		def colrow
			in_play? ? @col.downcase + @row.downcase : '(not on board)'
		end

		def to_s
			color == WHITE ? @ascii.upcase : @ascii.downcase
		end

		def inspect
			"#<#{self.class}:#{object_id} @color=#{@color.inspect} @col=#{@col.inspect} @row=#{@row.inspect} @moved=#{@moved.inspect}>"
		end
		
		def name
			self.class.to_s[ /[^:]+$/, 0 ]
		end
		
		def capturing_moves
			possible_moves.select{ |move| move.captured_piece }
		end

		def noncapturing_moves
			possible_moves.select{ |move| !move.captured_piece }
		end
	
		class Move
			attr_reader :piece, :col, :row, :captured_piece, :also_move
			# _piece_:: The piece to move
			# _dest_col_:: The destination column ('a'..'h')
			# _dest_row_:: The destination row ('1'..'8')
			# _capture_:: The piece to capture (optional)
			# _also_move_:: A related Move to carry out at the same time (optional)
			def initialize( piece, dest_col, dest_row, capture=nil, also_move=nil )
				raise Board::OutOfBoundsError unless Board.in_bounds?( dest_col, dest_row )
				@piece = piece
				@col = dest_col
				@row = dest_row
				@captured_piece = capture
				@also_move = also_move
			end
			
			def inspect
				"#<#{self.class}:#{object_id} @piece=#{@piece.inspect} @col=#{@col.inspect} @row=#{@row.inspect} @captured_piece=#{@captured_piece.inspect} @also_move=#{@also_move.inspect}>"
			end
			
			def colrow
				@col.downcase+@row.downcase
			end
		end

	end

	class Pawn < Piece
		def initialize( *args )
			super
			@ascii = 'P'			
		end

		# An array of Moves that the pawn can currently perform.
		#
		# Accounts for other pieces on the board; accounts for en-passant.
		# Does not account for Check or Checkmate (that's up to the board)
		def possible_moves
			moves = []
			
			# Move one up, unless a piece is in the way
			next_row = ( color == WHITE ) ? @row.next : @row.prev
			begin	moves << Move.new( self, @col, next_row ) unless board[ @col, next_row ]
			rescue Board::OutOfBoundsError; end

			# Jump two ahead, if we could move one ahead
			if !moved? && moves.length > 0
				jump_row = ( color == WHITE ) ? next_row.next : next_row.prev
				begin	moves << Move.new( self, @col, jump_row ) unless board[ @col, jump_row ]
				rescue Board::OutOfBoundsError; end
			end

			# Capture diagonally one way...			
			col = @col.next
			dest_piece = board[ col, next_row ]
			if dest_piece && dest_piece.color != color
				begin moves << Move.new( self, col, next_row, dest_piece ) 
				rescue Board::OutOfBoundsError; end
			end

			# ...and then the other
			col = @col.prev
			dest_piece = board[ col, next_row ]
			if dest_piece && dest_piece.color != color
				begin moves << Move.new( self, col, next_row, dest_piece ) 
				rescue Board::OutOfBoundsError; end
			end
			
			# todo - en-passant
			
			moves
		end
		
	end

	class Rook < Piece
		def initialize( *args )
			super
			@ascii = 'R'
		end

		# An array of Moves that the rook can currently perform.
		#
		# Accounts for other pieces on the board.
		# Does not account for castling (that's up to the King).
		# Does not account for Check or Checkmate (that's up to the board)
		def possible_moves
			moves = []

			[ :row, :col ].each{ |axis|
				[ :next, :prev ].each{ |dir|
					cur_col, cur_row = @col, @row
					hit_piece = false
					while ( !hit_piece )
						case axis
							when :col then cur_col = cur_col.send( dir )
							when :row then cur_row = cur_row.send( dir )
						end
						hit_piece = board[ cur_col, cur_row ]
						if !hit_piece or hit_piece.color != self.color
							begin
								moves << Move.new( self, cur_col, cur_row, hit_piece )
							rescue Board::OutOfBoundsError
								break
							end
						end
					end
				}
			}
			
			moves
		end
	end

	class Bishop < Piece
		def initialize( *args )
			super
			@ascii = 'B'
		end

		# An array of Moves that the bishop can currently perform.
		#
		# Accounts for other pieces on the board.
		# Does not account for castling (that's up to the King).
		# Does not account for Check or Checkmate (that's up to the board)
		def possible_moves
			moves = []

			[ [ :next, :next ], [ :next, :prev ], [ :prev, :prev], [ :prev, :next ] ].each{ |axis|
				cur_col, cur_row = @col, @row
				hit_piece = false
				while ( !hit_piece )
					cur_col = cur_col.send( axis[0] )
					cur_row = cur_row.send( axis[1] )
					hit_piece = board[ cur_col, cur_row ]
					if !hit_piece or hit_piece.color != self.color
						begin
							moves << Move.new( self, cur_col, cur_row, hit_piece )
						rescue Board::OutOfBoundsError
							break
						end
					end
				end
			}
			
			moves
		end
	end

	class Knight < Piece
		def initialize( *args )
			super
			@ascii = 'N'
		end

		def possible_moves
			moves = []

			offsets = [ -2, -1, 1, 2 ]
			offsets.each{ |col_move|
				offsets.each{ |row_move|
					next if col_move == row_move
					case col_move
						when -2 then cur_col = @col.prev.prev
						when -1 then cur_col = @col.prev
						when 1 then cur_col = @col.next
						when 2 then cur_col = @col.next.next
					end
					case row_move
						when -2 then cur_row = @row.prev.prev
						when -1 then cur_row = @row.prev
						when 1 then cur_row = @row.next
						when 2 then cur_row = @row.next.next
					end

					hit_piece = board[ cur_col, cur_row ]
					next if hit_piece && hit_piece.color == self.color

					begin moves << Move.new( self, cur_col, cur_row, hit_piece )
					rescue Board::OutOfBoundsError; end
				}
			}

			moves
		end
	end

	class King < Piece
		def initialize( *args )
			super
			@ascii = 'K'
		end

		def possible_moves
			moves = []

			offsets = [ -1, 0, 1 ]
			offsets.each{ |col_move|
				offsets.each{ |row_move|
					case col_move
						when -1 then cur_col = @col.prev
						when 0 then cur_col = @col
						when 1 then cur_col = @col.next
					end
					case row_move
						when -1 then cur_row = @row.prev
						when 0 then cur_row = @row
						when 1 then cur_row = @row.next
					end

					hit_piece = board[ cur_col, cur_row ]
					next if hit_piece && hit_piece.color == self.color

					begin moves << Move.new( self, cur_col, cur_row, hit_piece )
					rescue Board::OutOfBoundsError; end
				}
			}
			
			moves
		end
	end

	class Queen < Piece
		def initialize( *args )
			super
			@ascii = 'Q'
		end

		def possible_moves
			moves = []

			# Axis moves
			[ :row, :col ].each{ |axis|
				[ :next, :prev ].each{ |dir|
					cur_col, cur_row = @col, @row
					hit_piece = false
					while ( !hit_piece )
						case axis
							when :col then cur_col = cur_col.send( dir )
							when :row then cur_row = cur_row.send( dir )
						end
						hit_piece = board[ cur_col, cur_row ]
						if !hit_piece or hit_piece.color != self.color
							begin
								moves << Move.new( self, cur_col, cur_row, hit_piece )
							rescue Board::OutOfBoundsError
								break
							end
						end
					end
				}
			}

			# Diagonal moves
			[ [ :next, :next ], [ :next, :prev ], [ :prev, :prev], [ :prev, :next ] ].each{ |axis|
				cur_col, cur_row = @col, @row
				hit_piece = false
				while ( !hit_piece )
					cur_col = cur_col.send( axis[0] )
					cur_row = cur_row.send( axis[1] )
					hit_piece = board[ cur_col, cur_row ]
					if !hit_piece or hit_piece.color != self.color
						begin
							moves << Move.new( self, cur_col, cur_row, hit_piece )
						rescue Board::OutOfBoundsError
							break
						end
					end
				end
			}
			
			moves
		end

	end

	class Board
		COLS = 'a'..'h'
		ROWS = '1'..'8'

		attr_reader :turn, :move_number

		def self.in_bounds?( col, row=nil )
			col,row = col.to_s.split( '' ) unless row
			return false unless row
			col.downcase!
			row.downcase!
			COLS.include?( col ) && ROWS.include?( row )
		end

		def initialize
			@squares = {}
			@pieces = { Piece::WHITE => [], Piece::BLACK => [] }			
			@kings = {}
			reset!
		end

		def reset!
			@turn = Piece::WHITE
			@move_number = 1

			#Populate the board
			COLS.each{ |col|
				@pieces[ Piece::WHITE ] << self[ col,'2' ] = Pawn.new( self, Piece::WHITE )
				@pieces[ Piece::BLACK ] << self[ col,'7' ] = Pawn.new( self, Piece::BLACK )
			}

			@pieces[ Piece::WHITE ] << self[ 'a1' ] = Rook.new( self, Piece::WHITE )
			@pieces[ Piece::WHITE ] << self[ 'h1' ] = Rook.new( self, Piece::WHITE )
			@pieces[ Piece::BLACK ] << self[ 'a8' ] = Rook.new( self, Piece::BLACK )
			@pieces[ Piece::BLACK ] << self[ 'h8' ] = Rook.new( self, Piece::BLACK )

			@pieces[ Piece::WHITE ] << self[ 'b1' ] = Knight.new( self, Piece::WHITE )
			@pieces[ Piece::WHITE ] << self[ 'g1' ] = Knight.new( self, Piece::WHITE )
			@pieces[ Piece::BLACK ] << self[ 'b8' ] = Knight.new( self, Piece::BLACK )
			@pieces[ Piece::BLACK ] << self[ 'g8' ] = Knight.new( self, Piece::BLACK )

			@pieces[ Piece::WHITE ] << self[ 'c1' ] = Bishop.new( self, Piece::WHITE )
			@pieces[ Piece::WHITE ] << self[ 'f1' ] = Bishop.new( self, Piece::WHITE )
			@pieces[ Piece::BLACK ] << self[ 'c8' ] = Bishop.new( self, Piece::BLACK )
			@pieces[ Piece::BLACK ] << self[ 'f8' ] = Bishop.new( self, Piece::BLACK )

			@pieces[ Piece::WHITE ] << self[ 'e1' ] = Queen.new( self, Piece::WHITE )
			@pieces[ Piece::BLACK ] << self[ 'e8' ] = Queen.new( self, Piece::BLACK )

			@pieces[ Piece::WHITE ] << self[ 'd1' ] = King.new( self, Piece::WHITE )
			@pieces[ Piece::BLACK ] << self[ 'd8' ] = King.new( self, Piece::BLACK )

			@kings[ Piece::WHITE ] = self[ 'd1' ]
			@kings[ Piece::BLACK ] = self[ 'd8' ]
		end
				
		def []( col, row=nil )
			@squares[ col.to_s.downcase + row.to_s.downcase ]
		end
		
		def []=( col, row, piece=nil )
			unless piece
				piece = row
				col, row = col.to_s.split( '' )
			end
			col.downcase!
			row.downcase!
			if ( dest_piece = @squares[ col+row ] )
				dest_piece.captured!
				@pieces[ dest_piece.color ].delete( dest_piece )
			end
			@squares[ piece.col + piece.row ] = nil if piece.in_play?
			@squares[ col + row ] = piece
			piece.position = [ col, row ]
		end

		def legal_move( piece, dest_colrow )
			dest_colrow = dest_colrow.to_s
			moves = piece.possible_moves
			
			#todo - add in en-passant and castling here

			return false unless move = moves.find{ |move|
				move.colrow == dest_colrow
			}

			scenario = self.deep_clone
			scenario[ dest_colrow ] = scenario[ piece.colrow ]
			return false if scenario.king_in_check?( piece.color )
			
			move
		end

		# Returns true if the _color_ King is in check
		def king_in_check?( color )
			king = @kings[ color ]
			other_team = @pieces[ Piece::OTHER_COLOR[ color ] ]
			other_team.collect{ |piece| piece.capturing_moves }.flatten.find{ |move|
				move.captured_piece == king
			}
		end

		def move( src_colrow, dest_colrow )
			src_colrow.downcase!
			dest_colrow.downcase!
			begin
				raise IllegalMoveError, "#{src_colrow.inspect} is not a valid board position" unless Board.in_bounds?( src_colrow )
				raise IllegalMoveError, "#{dest_colrow.inspect} is not a valid board position" unless Board.in_bounds?( dest_colrow )
				raise IllegalMoveError, "No piece exists at #{src_colrow} to move" unless piece = self[ src_colrow ]
				raise IllegalMoveError, "It is #{@turn}'s move" unless piece.color == @turn
							
				dest_colrow = dest_colrow.to_s
				raise IllegalMoveError, "#{piece.name} at #{piece.colrow} cannot move to #{dest_colrow}" unless move = legal_move( piece, dest_colrow )
				
				move.captured_piece.captured! if move.captured_piece
				self[ dest_colrow ] = piece
			
				@turn = Piece::OTHER_COLOR[ @turn ]
				@move_number += 1

				#todo - check for check_mate
			rescue IllegalMoveError => err
				puts err
				# Pretend it never happened
			end
		end
		
		def game_over?
			false
		end
		
		def to_s
			rows = []
			ROWS.each{ |row|
				rowout = "#{row} "
				COLS.each{ |col|
					rowout << ( self[ col, row ] || '-' ).to_s
					rowout << ' '
				}
				rows.unshift( rowout )
			}
			rows.unshift( "  #{COLS.to_a.join(' ').upcase}" )
			rows.join( "\n" )
		end

		class OutOfBoundsError < RuntimeError; end
		class IllegalMoveError < RuntimeError; end
	end
end

class String
	# Very hacky complement to String#next
	def prev
		if length==1
			(self[0]-1).chr
		else
			self.sub( /.$/ ){ |last_char| (last_char[0]-1).chr }
		end
	end
end

class Array
	def inspect_each
		out = ''
		each{ |o| out << o.inspect + "\n" }
		out
	end
end

class Object
	def deep_clone
	    Marshal.load(Marshal.dump(self))
	  end
end

if $0 == __FILE__
	include GKChess
	require "rubygems"
	require "highline/import"
	board = Board.new
	while !board.game_over?
		puts "\n#{board}\n\n"
		puts "Move ##{board.move_number}, #{board.turn}'s turn"
		#puts "(#{@turn} is in check)" if board.king_in_check?( @turn )

		piece = ask( "\tPiece to move: ", lambda { |loc| board[ loc ] } ){ |q|
			q.responses[ :not_valid ] = ""
			q.validate = lambda { |loc|
				case loc
					when /[a-h][1-8]/i
						if piece = board[ loc ]
							if piece.color == board.turn
								if !piece.possible_moves.empty?
									true
								else
									puts "That #{piece.name} has no legal moves available."
									false
								end
							else
								puts "The #{piece.name} at #{loc} does not belong to #{board.turn}!"
								false
							end
						else
							puts "There is no piece at #{loc}!"
							false
						end
					else
						puts "(Please enter the location such as a8 or c3)" 
						false
				end
			}
		}

		valid_locations = piece.possible_moves.collect{ |move| move.colrow }

		dest = ask( "\tMove #{piece.name} to: " ){ |q|
			q.responses[ :not_valid ] = "The #{piece.name} cannot move there. Valid moves: #{valid_locations.sort.join( ', ' )}."
			q.validate = lambda { |loc| valid_locations.include?( loc.downcase ) }
		}

		board.move( piece.colrow, dest )
	end
end