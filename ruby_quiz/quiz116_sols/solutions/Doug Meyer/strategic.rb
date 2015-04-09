#!/usr/bin/env ruby -w

class StrategicBot
  def reset
    @my_cards = (1..13).to_a
  end
  alias_method :initialize, :reset
  
  def play_card(bid_card)
    close_cards = @my_cards.sort_by{|c| (bid_card+0.45+(rand)-c).abs}[0..2]
    play_card = (close_cards).first
    play_card = close_cards.first if play_card.nil?

    @my_cards.delete(play_card)
  end
  
  def play
    reset
    until @my_cards.empty?
      $stdout.puts play_card( $stdin.gets[/\d+/].to_i )
      $stdout.flush
      $stdin.gets[/\d+/]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  StrategicBot.new.play
end
