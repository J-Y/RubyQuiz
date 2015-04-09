#!/usr/bin/env ruby -w

class Player
  CARDS = (1..13).to_a

  def initialize
    @cards_left = CARDS.dup
    @wins       = Array.new
  end
  
  attr_reader :cards_left
  protected   :cards_left
  
  def play_card(card)
    @cards_left.delete(card)
  end
  
  def win_card(bid_card)
    @wins << bid_card
  end
end


class Planner < Player
  def initialize
    super
    
    @bids_left = CARDS.dup
    @opponent  = Player.new
    
    @sure_wins = Hash.new
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
  end
  
  private
  
  def choose_a_card
    find_sure_wins
    
    @sure_wins[@bidding_for] || @cards_left.min
  end
  
  def find_sure_wins
    ((@opponent.cards_left.max + 1)..13).to_a.reverse_each do |card|
      next unless @cards_left.include?       card
      next if     @sure_wins.values.include? card
      
      @sure_wins[(@bids_left - @sure_wins.keys).max] = card
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  planner = Planner.new
  13.times do
    $stdout.puts planner.bid_on_card($stdin.gets[/\d+/].to_i)
    $stdout.flush
    planner.record_result($stdin.gets[/\d+/].to_i)
  end
end
