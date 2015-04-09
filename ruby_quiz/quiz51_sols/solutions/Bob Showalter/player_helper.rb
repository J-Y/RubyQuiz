# = PlayerHelper
#
# include this module in your player class to provide
# parsing of the game data provided through the show
# method.
#
# Your player class needs to provide two methods:
#
#   play_card  - called when it's your turn to play a card.
#                return the card to play, or 'd' + card to
#                discard a card.
#   draw_card  - called when it's your turn to draw a card.
#                return the pile to draw from [domjv], or 'n'
#                to draw from the deck.
#
# The default methods implement the DumbPlayer logic, so the
# simplest player would be:
#
#   require 'player_helper'
#   class SimplePlayer < Player
#      include PlayerHelper
#   end
#

module PlayerHelper

  # Last error message returned from engine, or nil if no error
  attr_reader :error

  # Hash by land. Each entry is an Array of Game::Card's discarded
  # for that land.
  attr_reader :discards

  # Array of "unseen" Game::Card's. These are either in the deck or
  # in the opponents hand (but not seen by the current player)
  attr_reader :unseen

  # Number of cards still available in the deck
  attr_reader :deck

  # Current player's hand (Array of Game::Card's)
  attr_reader :my_hand

  # Hash by land for current player. Each entry is an Array of
  # Game::Card's played to that land.
  attr_reader :my_lands

  # Cards *known* to be in opponent's hand (Array of Game::Card's).
  # These are determined by the discards the opponent picks up. Cards
  # that the opponent was initially dealt or have drawn from the deck
  # will appear in :unseen
  attr_reader :op_hand

  # Hash by land for Opponent. Each entry is an Array of
  # Game::Card's played to that land.
  attr_reader :op_lands

  def self.included(klass)

    # enables echoing of game data from engine
    def klass.echo_on
      @echo = true
    end

    # disables echoing of game data from engine
    def klass.echo_off
      @echo = false
    end

  end

  # intializes game state data
  def initialize
    super
    @op_hand = Array.new
    @my_hand = Array.new
    @unseen = Array.new
    @op_lands = Hash.new
    @discards = Hash.new
    @my_lands = Hash.new
    Game::LANDS.each do |land|
      @op_lands[land] = Array.new
      @discards[land] = Array.new
      @my_lands[land] = Array.new
    end
    moveover
    gameover
  end

  # draws one or more cards in readable format
  def draw_cards(*cards)
    cards.flatten.map {|c| c.to_s}.join(' ')
  end

  # clears some game state data when game ends. helpful when the
  # same player object is used for multiple games.
  def gameover
    op_hand.clear
  end

  def show( game_data )
    puts game_data.chomp if self.class.class_eval "@echo"
    game_data.strip!
    if game_data =~ /^(\S+):/ && @my_lands.has_key?($1.downcase)
      @land = $1.downcase
      return
    end
    case game_data
      when /Hand:\s+(.+?)\s*$/
        my_hand.replace($1.split.map { |c| Game::Card.parse(c) })
      when /Opponent:(.*?)(?:\(|$)/
        op_lands[@land].replace($1.split.map { |c|
          Game::Card.parse("#{c}#{@land[0,1]}") })
      when /Discards:(.*?)(?:\(|$)/
        discards[@land].replace($1.split.map { |c|
          Game::Card.parse("#{c}#{@land[0,1]}") })
      when /You:(.*?)(?:\(|$)/
        my_lands[@land].replace($1.split.map { |c|
          Game::Card.parse("#{c}#{@land[0,1]}") })
      when /Your opponent (?:plays|discards) the (\w+)/
        c = Game::Card.parse($1)
        i = op_hand.index(c)
        op_hand.delete_at(i) if i
      when /Your opponent picks up the (\w+)/
        op_hand << Game::Card.parse($1)
      when /Draw from\?/
        @action = :draw_card
      when /Your play\?/
        @action = :play_card
      when /^Error:/
        @error = game_data
      when /Deck:.*?(\d+)/
        @deck = $1
      when /Game over\./
        gameover
      else
        #puts "Unhandled game_data: #{game_data}"
    end
  end

  def move
    find_unseen if error.nil?
    send(@action)
  ensure
    moveover
  end

  # returns a full deck of cards
  def full_deck
    Game::LANDS.collect do |land|
      (['Inv'] * 3 + (2 .. 10).to_a).collect do |value|
        Game::Card.new(value, land)
      end
    end.flatten
  end

  # after all the board data has been received, determines
  # which cards from the deck have not yet been seen. these
  # are either in the deck or known to be in the opponent's hand.
  def find_unseen
    unseen.replace(full_deck)
    (my_hand + op_hand + my_lands.values +
      op_lands.values + discards.values).flatten.each do |c|
      i = unseen.index(c) or next
      unseen.delete_at(i)
    end
  end

  def moveover
    @error = nil
  end

  # naive draw method: always draws from deck
  # (override this in your player)
  def draw_card
    "n"
  end

  # naive play method: plays first playable card in hand,
  # or if no legal play, just discards the first card in
  # the hand.
  # (override this in your player)
  def play_card
    card = @my_hand.find { |c| live?(c) }
    return card.to_play if card
    "d" + @my_hand.first.to_play
  end

  # returns true if card is playable on given lands. cards
  # that are not live can never be played, so are just dead
  # weight in your hand (although they may be useful to your
  # opponent; you can check this with live?(card, op_lands).)
  def live?(card, lands = @my_lands)
    lands[card.land].empty? or lands[card.land].last <= card
  end

end

# extend the Game::Card class with some helpers
class Game::Card

  # define a comparison by rank and land.
  # useful for sorting hands, etc.
  include Comparable
  def <=>(other)
    result = value.to_i <=> other.value.to_i
    if result == 0
      result = land <=> other.land
    end
    result
  end

  # returns true if two cards have same land
  def same_land?(other)
    land == other.land
  end

  # parse a card as shown by Game#draw_cards back to a
  # Game::Card object. Investment cards can be specified
  # as 'I' or 'Inv'.
  def self.parse(s)
    value, land = s.strip.downcase.match(/(.+)(.)/).captures
    if value =~ /^i(nv)?$/
      value = 'Inv'
    else
      value = value.to_i
      value.between?(2,10) or raise "Invalid value"
    end
    land = Game::LANDS.detect {|l| l[0,1] == land} or
      raise "Invalid land"
    new(value, land)
  end

  # converts a card to its string representation (value + land)
  def to_s
    "#{value}#{land[0,1].upcase}"
  end

  # converts a card to its play representation
  def to_play
    "#{value.is_a?(String) ? value[0,1] : value}#{land[0,1]}".downcase
  end

end
