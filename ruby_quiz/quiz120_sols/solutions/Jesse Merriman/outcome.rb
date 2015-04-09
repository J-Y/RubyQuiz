#!/usr/bin/env ruby
# outcome.rb
# Ruby Quiz 120: Magic Fingers

require 'constants'

module Outcome
  # Order important: from best-for-player-1 to best-for-player-2
  Outcome::P1Win   = 0
  Outcome::Unknown = 1
  Outcome::P2Win   = 2

  # Given an Enumerable of outcomes, return the one that is best for the given
  # player.
  def Outcome.best(player, outcomes)
    best = (player == Player1) ? outcomes.min : outcomes.max
    best.nil? ? Outcome::Unknown : best
  end
end
