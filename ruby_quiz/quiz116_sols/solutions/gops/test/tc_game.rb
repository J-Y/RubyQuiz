#!/usr/bin/env ruby -w

require "test/unit"

require "gops"

class TestGame < Test::Unit::TestCase
  include GOPS
  
  def setup
    @low_player  = Player.new("ordered")
    @high_player = Player.new("ordered", 2)
    @game        = Game.new(@low_player, @high_player)
  end
  
  def test_game_creation
    assert_equal([@low_player, @high_player], @game.players)
    assert_equal(CARDS, @game.bid_cards.sort)
  end
  
  def test_play_round
    prize = @game.bid_cards.first
    assert_equal( [prize, 1, 2],
                  @game.play_round do |round, bid_card, low_play, high_play|
                    assert_equal(@game, round)
                    assert_equal(prize, bid_card)
                    assert_equal(1, low_play)
                    assert_equal(2, high_play)
                  end )
    assert_equal(0, @low_player.score)
    assert_equal(prize, @high_player.score)
  end
  
  def test_play
    final_card = @game.bid_cards.last
    @game.play
    assert_equal(final_card, @low_player.score)
    assert_equal( (1..13).inject { |sum, card| sum + card } - final_card,
                  @high_player.score )
    assert_equal(@high_player, @game.winner)
  end
end
