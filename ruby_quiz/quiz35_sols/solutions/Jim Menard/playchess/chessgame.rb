require 'bangkok/chessgame'
require 'board'

class ChessGame

  def play(io=nil)
    @listener.start_game(io)
    @board = Board.new(@listener)
    @board.draw
    game_loop()
    @listener.end_game
  end

  def game_loop()
    turn = :white
    loop do
      print "#{turn.to_s.capitalize}: "
      break unless line = gets
      move = Move.new(turn, line.chomp.strip)
      begin
        @board.apply(move)
        turn = turn == :white ? :black : :white
      rescue => e
        puts e.to_s
        # Don't change turn; make same player try again
      end
    end
  end

end
