#!/usr/bin/env ruby -w

class RandomBot
  def reset
    @cards = (1..13).sort_by { rand }
  end
  alias_method :initialize, :reset
  
  def play_card
    @cards.shift
  end
  
  def play
    until @cards.empty?
      $stdin.gets # competition card--ignored
      $stdout.puts play_card
      $stdout.flush
      $stdin.gets # opponent's bid--ignored
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  RandomBot.new.play
end
