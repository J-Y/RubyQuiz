#!/usr/bin/env ruby -w

require "test/unit"

require "gops"

class TestOrderedBot < Test::Unit::TestCase
  include GOPS
  
  def test_default_order_implicit
    assert_equal(CARDS, plays_from_bot)
  end
  
  def test_default_order_explicit
    assert_equal(CARDS, plays_from_bot(1))
  end
  
  def test_start_card
    assert_equal((7..13).to_a + (1...7).to_a, plays_from_bot(7))
  end
  
  private
  
  def plays_from_bot(start_card = nil)
    bot = Player.new("ordered", *Array(start_card))
    
    Array.new(13) do
      card = bot.play_card(13)
      bot.send_opponents_play(13)
      card
    end
  end
end
