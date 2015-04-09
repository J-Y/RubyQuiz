#!/usr/bin/env ruby
require 'delegate'
require 'alphabeta'
require 'tictactoe'
require 'tictactoe-interface'

include AlphaBeta

# A state for minimax-ab
# Encapsulates a board and adds a evaluation and a each_successor function to the board.
class TicTacToeState < DelegateClass(Board)
  def initialize(board = Board.new)
    super(board)
  end
    
  def each_successor
    self.moves.each do | move | yield(self.class.new(self.make(move)), move) end
  end

  def value
    w = self.winner
    return w == self.player ? 100 : -100 if w
    return 0
  end

  def to_s
    __getobj__.to_s + "Value: #{value}\n"
  end
end

module Interface
  # The perfect player
  class AlphaBeta < BasicInterface
    def choose_move(game)
      alpha_beta_r(TicTacToeState.new(game))[1]
    end
  end

  # The imperfect, time limited player. Quite bad, because we don't have a good evaluation function to lead the search.
  class AlphaBetaLimited < BasicInterface
    attr_accessor :max_think_time
    
    def choose_move(game)
      alpha_beta_timed(TicTacToeState.new(game), max_think_time)[1]
    end
  end
end

# If this file is executed, starts a Alphabeta vs. Human game.
#
# You won't have much fun with this, as your can't play better than draw against the machine.
if __FILE__ == $0 
  player0 = Interface::NaturalIntelligence.new
  #player0 = Interface::AlphaBeta.new
  player1 = Interface::AlphaBeta.new
  play_game(player0, player1)
end
