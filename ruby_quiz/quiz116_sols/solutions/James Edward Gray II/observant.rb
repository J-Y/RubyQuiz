#!/usr/bin/env ruby -w

class Player
  CARDS = (1..13).to_a

  def initialize
    @cards_left = CARDS.dup
    @wins       = Array.new
  end
  
  def play_card(card)
    @cards_left.delete(card)
  end
  
  def win_card(bid_card)
    @wins << bid_card
  end
  
  def score
    @wins.inject { |sum, card| sum + card } || 0
  end
end


class Observant < Player
  BRAIN = "memory.dump"
  
  def initialize
    super
    
    @bids_left = CARDS.dup
    @opponent  = Player.new
    
    @memory    = File.open(BRAIN) { |file| Marshal.load(file) } rescue Array.new
    @this_game = Array.new
  end
  
  def bid_on_card(card)
    @bidding_for = card
    @last_play   = choose_a_card
  end
  
  def record_result(opponents_card)
    if @last_play > opponents_card
      win_card(@bidding_for)
    elsif opponents_card > @last_play
      @opponent.win_card(@bidding_for)
    end
    
    @bids_left.delete(@bidding_for)
    play_card(@last_play)
    @opponent.play_card(opponents_card)
    
    @this_game[@bidding_for] = opponents_card
  end
  
  def memorize_game
    File.open(BRAIN, "w") { |file| Marshal.dump(@this_game, file) }
  end
  
  private
  
  def choose_a_card
    if @memory.empty?
      @bidding_for
    else
      expected = @memory[@bidding_for]
      expected == 13 ? 1 : expected + 1
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  observant = Observant.new
  13.times do
    $stdout.puts observant.bid_on_card($stdin.gets[/\d+/].to_i)
    $stdout.flush
    observant.record_result($stdin.gets[/\d+/].to_i)
  end
  observant.memorize_game
end
