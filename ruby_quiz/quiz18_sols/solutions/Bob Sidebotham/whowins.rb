require 'tactics'

puts %(#{Tactics.new.play == Tactics::WIN ? "First" : "Second"} player wins.)
