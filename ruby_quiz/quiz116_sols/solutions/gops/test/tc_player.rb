#!/usr/bin/env ruby -w

require "test/unit"

require "gops"

class TestPlayer < Test::Unit::TestCase
  include GOPS
  
  def setup
    @player = Player.new("random")
  end
  
  def test_requires_an_existing_bot_file
    assert_raise(RuntimeError) { Player.new("does_not_exist") }
    assert_nothing_raised(RuntimeError) do
      Player.new(File.join(BOT_DIR, "random.rb"))
    end
  end
  
  def test_bot_dir_path_is_optional
    assert_nothing_raised(RuntimeError) { Player.new("random.rb") }
  end
  
  def test_bot_file_extension_is_optional
    assert_nothing_raised(RuntimeError) { Player.new("random") }
  end
  
  def test_can_pass_arguments
    assert_equal(2, Player.new("ordered", 2).play_card(13))
  end
  
  def test_name_is_built_from_file_name_and_arguments
    assert_equal("Ordered_2", Player.new("ordered", 2).name)
  end
  
  def test_default_deck
    assert_equal(CARDS, @player.cards)
  end
  
  def test_play_card
    played = Array.new
    13.times do
      played << @player.play_card(13)
      assert(CARDS.include?(played.last), "Invalid card.")
      assert_equal(CARDS - played, @player.cards)
      @player.send_opponents_play(played.last)
    end
    
    assert_equal(CARDS, played.sort)
  end
  
  def test_illegal_play
    assert_raise(RuntimeError) do
      Player.new("illegal_player").play_card(13)
    end
  end
  
  def test_win_card_and_score
    @player.win_card(13)
    assert_equal(13, @player.score)

    @player.win_card(2)
    assert_equal(13 + 2, @player.score)
  end
end
