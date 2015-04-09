require 'bangkok/board'

class Board

  alias old_apply apply
  def apply(move)
    old_apply(move)
    draw
  end

  def draw
    color = :white
    7.downto(0) { | rank |
      (0..7).each { | file |
        draw_square(file, rank)
      }
      puts
    }
  end

  def draw_square(file, rank)
    square = Square.at(file, rank)
    piece = at(square)
    print(piece.nil? ? '    ' :
            " #{piece.color.to_s[0,1].capitalize}#{piece.piece} ")
  end

end
