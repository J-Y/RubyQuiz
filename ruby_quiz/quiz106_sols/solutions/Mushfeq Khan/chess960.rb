require 'dlx'
class Piece
  attr_reader :column
  def initialize(column)
    @column = column
  end
  def column_constraint
    octet_with_ones_at(@column)
  end
  def rook_king_constraint
    [0]*8
  end
  def bishop_constraint
    [0]*8
  end
  def knight_constraint
    [0]*8
  end
  def octet_with_ones_at(*indexes)
    result = [0]*8
    indexes.each {|i| result[i] = 1}
    result
  end
  def same_color_columns(column)
    column % 2 == 0 ? [0, 2, 4, 6] : [1, 3, 5, 7]
  end
  def bishop_color_constraint
    [0]
  end
  def to_dlx_row
    piece_constraint + column_constraint + rook_king_constraint + bishop_constraint + knight_constraint + bishop_color_constraint
  end
end

class LeftRook < Piece
  def piece_constraint
    octet_with_ones_at(0)
  end
  def rook_king_constraint
    octet_with_ones_at(*(0..@column).to_a)
  end
  def to_s
    "Left Rook at #{@column}"
  end
  def symbol
    'R'
  end
end

class RightRook < Piece
  def piece_constraint
    octet_with_ones_at(7)
  end
  def rook_king_constraint
    octet_with_ones_at(*(@column..7).to_a)
  end
  def to_s
    "Right Rook at #{@column}"
  end
  def symbol
    'R'
  end
end

class King < Piece
  def piece_constraint
    octet_with_ones_at(4)
  end
  def rook_king_constraint
    column_constraint
  end
  def to_s
    "King at #{@column}"
  end
  def symbol
    'K'
  end
end

class Queen < Piece
  def piece_constraint
    octet_with_ones_at(3)
  end
  def to_s
    "Queen at #{@column}"
  end
  def symbol
    'Q'
  end
end

class Filler < Piece
  def column_constraint
    [0]*8
  end
  def piece_constraint
    [0]*8
  end
  def to_s
    "Filler"
  end
end

class KnightFiller < Filler
  def knight_constraint
    octet_with_ones_at(@column)
  end
end

class RookFiller < Filler
  def rook_king_constraint
    octet_with_ones_at(@column)
  end
end

class BishopFiller < Filler
  def bishop_constraint
    octet_with_ones_at(@column)
  end
end


class LeftKnight < Piece
  def piece_constraint
    octet_with_ones_at(1)
  end
  def knight_constraint
    octet_with_ones_at(*(0..@column).to_a)
  end
  def to_s
    "Left Knight at #{@column}"
  end
  def symbol
    'N'
  end
end

class RightKnight < Piece
  def piece_constraint
    octet_with_ones_at(6)
  end
  def knight_constraint
    octet_with_ones_at(*(@column..7).to_a)
  end
  def to_s
    "Right Knight at #{@column}"
  end
  def symbol
    'N'
  end
end

class LeftBishop < Piece
  def piece_constraint
    octet_with_ones_at(2)
  end
  def bishop_color_constraint
    @column % 2 == 0 ? [1] : [0]
  end
  def bishop_constraint
    octet_with_ones_at(*(0..@column).to_a)
  end
  def to_s
    "Left Bishop at #{@column}"
  end
  def symbol
    'B'
  end
end

class RightBishop < Piece
  def piece_constraint
    octet_with_ones_at(5)
  end
  def bishop_color_constraint
    @column % 2 == 0 ? [1] : [0]
  end
  def bishop_constraint
    octet_with_ones_at(*(@column..7).to_a)
  end
  def to_s
    "Right Bishop at #{@column}"
  end
  def symbol
    'B'
  end
end

def to_board(placements)
  result = []
  placements.each do |placement|
    result[placement.column] = placement.symbol unless Filler === placement
  end
  result.join('')
end

placements = []
0.upto(5) {|col| placements << LeftRook.new(col)}
0.upto(6) {|col| placements << LeftKnight.new(col) << LeftBishop.new(col)}
0.upto(7) {|col| placements << Queen.new(col)}
1.upto(6) {|col| placements << RookFiller.new(col) << King.new(col) << KnightFiller.new(col) << BishopFiller.new(col)}
1.upto(7) {|col| placements << RightKnight.new(col) << RightBishop.new(col)}
2.upto(7) {|col| placements << RightRook.new(col)}

d = DLXMatrix.new(placements.collect {|placement| placement.to_dlx_row})
n = 0
d.solutions do |solution|
  puts "Solution #{n}:"
  puts to_board(solution.collect{|index| placements[index]})
  n += 1
end
