#!/usr/bin/ruby -w
#
# Quiz 24: Texas Hold'em
# Solution by Glenn Parker

module Combine
  # Generate all combinations of +pick+ elements from +items+ array.
  def Combine.pick(pick, items, &block)
    combine([], 0, pick, items, &block)
  end

  private

  def Combine.combine(set, index, pick, items, &block)
    if pick == 0 or index == items.length
      yield set
    else
      set.push(items[index])
      combine(set, index + 1, pick - 1, items, &block)
      set.pop
      combine(set, index + 1, pick, items, &block) if
        pick < items.length - index
    end
  end
end

# One card, with a face [2-9TJQKA] and a suit [shdc].
class Card
  attr_reader :face, :suit

  Face_Ranks = {
    :A =>   12, :K =>   11, :Q =>   10, :J =>    9,
    :T =>    8, :"9" =>  7, :"8" =>  6, :"7" =>  5,
    :"6" =>  4, :"5" =>  3, :"4" =>  2, :"3" =>  1,
    :"2" =>  0
  }

  Suit_Ranks = {
    :s => 3, :h => 2, :d => 1, :c => 0
  }

  def initialize(face_suit)
    @face = face_suit[0].chr.to_sym
    raise "Invalid face \"#{@face}\"" unless Face_Ranks.has_key?(@face)
    @suit = face_suit[1].chr.to_sym
    raise "Invalid suit \"#{@suit}\"" unless Suit_Ranks.has_key?(@suit)
    freeze
  end

  def rank                      # Overall ranking in the deck.
    index * 4 + Suit_Ranks[@suit]
  end

  def index                     # Ranking, independent of suit.
    Face_Ranks[@face]
  end

  def to_s
    @face.to_s + @suit.to_s
  end
end

# A typed collection of up to five cards.
class Hand
  include Comparable            # Hands can be compared.

  attr_reader :hand_type, :cards

  Hand_Names = [
    "Folded",
    "High Card",
    "Pair",
    "Two Pair",
    "Three of a Kind",
    "Straight",
    "Flush",
    "Full House",
    "Four of a Kind",
    "Straight Flush",
    "Royal Flush"
  ]

  # Define constants by converting "High Card" to Hand::High_Card = 0.
  Hand_Names.each_with_index do |n, i|
    const_set(n.tr(" ", "_"), i)
  end

  def initialize(hand_type, cards)
    @hand_type = hand_type
    @cards = cards.dup
    freeze
  end

  def to_s
    @cards.join(" ") + " " + Hand_Names[@hand_type]
  end

  def <=>(other)
    if @hand_type != other.hand_type
      # Hand ranking dominates.
      return @hand_type <=> other.hand_type

    elsif @hand_type == Flush
      # Compare corresponding cards, highest to lowest.
      @cards.reverse.zip(other.cards.reverse) do |a, b|
        return a.index <=> b.index if a.index != b.index
      end
      return 0

    elsif @hand_type == Two_Pair
      # Compare the two highest pairs, then the remaining pairs
      self_indices = [@cards[0].index, @cards[2].index].sort!
      other_indices = [other.cards[0].index, other.cards[2].index].sort!
      if self_indices[1] != other_indices[1]
        return self_indices[1] <=> other_indices[1]
      else
        return self_indices[0] <=> other_indices[0]
      end

    else
      # All others types of hand are compared using their first card.
      return @cards[0].index <=> other.cards[0].index
    end
  end
end

# A collection of seven cards, from which Hands are extracted.
class Deal
  attr_reader :all_cards, :best_hand, :kickers

  def initialize(card_string)
    # Parse and sort the cards.  The sorting order chosen here is
    # important when extracting and comparing hands later.
    @all_cards = card_string.split(/ /).collect do |face_suit|
      Card.new(face_suit)
    end.sort_by { |card| card.rank }
    @hands = []
    if @all_cards.length == 7
      # Extract all possible hands if we got 7 cards.
      find_high_card
      find_groups
      find_two_pairs_and_full_house
      find_straight_and_flush
    else
      # Otherwise, make a folded hand.
      add_hand(Hand::Folded, @all_cards)
    end
    # Pick the best possible hand and determine the kickers.
    @best_hand = @hands.max
    @kickers = (@all_cards - @best_hand.cards).sort_by do |card|
      -card.rank
    end
  end

  private

  def add_hand(hand_type, cards)
    @hands << Hand.new(hand_type, cards)
  end

  def find_high_card
    add_hand(Hand::High_Card, [ @all_cards[-1] ])
  end

  def find_groups
    # Find the longest run of each face in @all_cards.
    start = 0
    while @all_cards[start]
      for stop in ((start + 1)..@all_cards.length)
        next if @all_cards[stop] and
          (@all_cards[start].face == @all_cards[stop].face)
        case (stop - start)
        when 4:
	    add_hand(Hand::Four_of_a_Kind,  @all_cards[start...stop])
        when 3:
	    add_hand(Hand::Three_of_a_Kind, @all_cards[start...stop])
        when 2:
	    add_hand(Hand::Pair,            @all_cards[start...stop])
        end
        break
      end
      start = stop
    end
  end

  def find_two_pairs_and_full_house
    pairs = @hands.find_all do |h|
      h.hand_type == Hand::Pair
    end
    threes = @hands.find_all do |h|
      h.hand_type == Hand::Three_of_a_Kind
    end
    # Find up to three combinations of two pairs.
    if (pairs.length > 1)
      Combine.pick(2, pairs) do |pair_hands|
        add_hand(Hand::Two_Pair,
		 pair_hands[0].cards + pair_hands[1].cards)
      end
    end
    # Each combination of a pair and three-of-a-kind is a full house.
    pairs.each do |pair|
      threes.each do |three|
        add_hand(Hand::Full_House, three.cards + pair.cards)
      end
    end
    # Two three-of-a-kinds yield two possible full-houses.
    if (threes.length > 1)
      add_hand(Hand::Full_House,
	       threes[0].cards + threes[1].cards[0..1])
      add_hand(Hand::Full_House,
	       threes[1].cards + threes[0].cards[0..1])
    end
    # We could combine four-of-a-kind and a pair for a full-house
    # but four-of-a-kind already beats a full-house.
  end

  def find_straight_and_flush
    # Examine all combinations of five cards
    Combine.pick(5, @all_cards) do |cards|
      is_flush = true
      is_straight = true
      1.upto(4) do |i|
        is_straight = false if
	  (cards[i].index != cards[i - 1].index + 1)
        is_flush = false if
	  (cards[i].suit != cards[0].suit)
      end
      # Add the best hand found in this iteration.
      case
      when (is_straight and is_flush and cards[0].face == :"T")
        add_hand(Hand::Royal_Flush, cards)
      when (is_straight and is_flush)
        add_hand(Hand::Straight_Flush, cards)
      when (is_flush)
        add_hand(Hand::Flush, cards)
      when (is_straight)
        add_hand(Hand::Straight, cards)
      end
    end
  end

end

# A card player that holds a Hand and some kickers.
class Player
  attr_reader :hand, :kickers
  attr_accessor :wins

  def initialize(hand, kickers)
    @hand = hand
    @kickers = kickers
    @wins = false
  end

  # Return <=> value comparing kickers from another Player.
  def compare_kickers(other)
    @kickers.zip(other.kickers) do |a_kicker, b_kicker|
      return  1 if a_kicker.index > b_kicker.index
      return -1 if a_kicker.index < b_kicker.index
    end
    return 0
  end
end

# Read the input.

players = []
while line = gets
  line.chomp!
  # Take first 20 chars only, making it easy to use previously
  # printed results as input for re-testing.
  deal = Deal.new(line[0, 20])
  players << Player.new(deal.best_hand, deal.kickers)
end

# Find the winner(s).

winners = []
players.each do |player|
  if winners.empty?
    winners << player
  elsif player.hand > winners[0].hand
    winners.clear
    winners << player
  elsif player.hand == winners[0].hand
    # Try to resolve ties based on kickers.
    comparison = player.compare_kickers(winners[0])
    if comparison >= 0
      winners.clear if comparison > 0
      winners << player
    end
  end
end
winners.each { |player| player.wins = true }

# Report the results.

players.each do |player|
  # Print cards sorted by face with kickers at the end.
  print((player.hand.cards + player.kickers).join(" "))
  # Print description of hand and (winner) flag
  if player.hand.hand_type > 0
    print " ", Hand::Hand_Names[player.hand.hand_type]
    print " (winner)" if player.wins
  end
  print "\n"
end
