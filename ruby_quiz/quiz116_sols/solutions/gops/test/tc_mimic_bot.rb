#!/usr/bin/env ruby -w

require "test/unit"

require "gops"

class TestMimicBot < Test::Unit::TestCase
  include GOPS
  
  def setup
    @bot = Player.new("mimic")
  end
  
  def test_mimics_bid_cards
    CARDS.sort_by { rand }.each do |card|
      assert_equal(card, @bot.play_card(card))
      @bot.send_opponents_play(13)
    end
  end
end
