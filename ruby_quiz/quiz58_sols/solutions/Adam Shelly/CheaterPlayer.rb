class Cheater < Player
  def choose_move
    k = (@side==KalahGame::TOP) ? 13 : 6
    @game.board.each_index {|i|
      unless  [6,13].include? i
        @game.board[k]+=@game.board[i]
        @game.board[i]=0
      end
    }
    @game.board[k]-=1
    @game.board[k-1]=1
    k-1
  end
end
