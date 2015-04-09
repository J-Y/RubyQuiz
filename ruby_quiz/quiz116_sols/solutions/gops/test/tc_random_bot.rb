#!/usr/bin/env ruby -w

require "test/unit"

require File.join(File.dirname(__FILE__), *%w[.. bot random.rb])

class TestRandomBot < Test::Unit::TestCase
  def setup
    @bot = RandomBot.new
  end
  
  def test_plays_are_random
    srand(1)
    first_set = all_plays

    srand(2)  # change rand() order
    second_set = all_plays
    
    assert_not_equal(first_set, second_set)
  end
  
  def test_plays_all_cards
    assert_equal((1..13).to_a, all_plays.sort)
  end
  
  private
  
  def all_plays
    Array.new(13) { @bot.play_card }
  end
end