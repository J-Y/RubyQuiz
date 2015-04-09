#!/usr/bin/env ruby
# game.rb
# Ruby Quiz 120: Magic Fingers

require 'constants'
require 'outcome'
require 'state'
require 'state_graph'

class Game
  # Constructor. p1_start and p2_start are Arrays containing the number of
  # fingers on each of their hands at the start of the game.
  def initialize(p1_start = [1,1], p2_start = [1,1])
    @graph = StateGraph.new(State.new(p1_start, p2_start, Player1))
    self
  end

  # Print out an analysis of the game.
  def analyze
    @graph.pull_up_outcomes
    outcome = @graph.root.best_outcome

    if outcome == Outcome::P1Win
      puts 'Player 1, with perfect play, can win.'
    elsif outcome == Outcome::P2Win
      puts 'No matter how well Player 1 plays, Player 2 can win.'
    elsif outcome == Outcome::Unknown
      puts 'Perfect play by both players leads to a loop.'
    else
      puts 'I am broken.'
    end
  end
end
