#!/usr/bin/env ruby
# magic_fingers.rb
# Ruby Quiz 120: Magic Fingers

require 'game'

# Note: These examples assume FingersPerHand == 5.

Game.new.analyze # Normal, default game.
#Game.new([1,1], [0,4]).analyze # P1 should win on move 1.
#Game.new([4,4], [1,1]).analyze # P1 should win on move 2.
#Game.new([0,1], [3,3]).analyze # P2 should win on move 2.
