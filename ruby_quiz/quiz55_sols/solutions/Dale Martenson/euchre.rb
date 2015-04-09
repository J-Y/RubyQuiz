class EuchreDeck
  def initialize
    # build a Euchre deck
    @cards = Array.new
    %w{9 T J Q K A}.each do |face|
      %w{d c s h}.each do |suit|
        @cards << face + suit
      end
    end
  end

  def shuffle
    @cards = @cards.sort_by { rand }
  end

  def deal
    @cards.shift
  end
end

class EuchreHand
  Suit = Struct.new( :suit, :alternate_suit_1, :off_suit, :alternate_suit_2 )

  @@suits = {
    "Diamonds"=>Suit.new("d","c","h","s"),
    "Clubs"=>Suit.new("c","h","s","d"),
    "Spades"=>Suit.new("s","d","c","h"),
    "Hearts"=>Suit.new("h","s","d","c")
  }

  @@face_values_trump = {
    "J" => 6,
    "A" => 4,
    "K" => 3,
    "Q" => 2,
    "T" => 1,
    "9" => 0
  }

  @@face_values_regular = {
    "A" => 5,
    "K" => 4,
    "Q" => 3,
    "J" => 2,
    "T" => 1,
    "9" => 0
  }

  MAX_CARDS_PER_SUIT = 7

  def initialize
    @trump = nil
    @hand = []
  end

  def left_brower?( card )
    card == "J#{@trump.off_suit}"
  end

  def trump?( card )
    card[1].chr == @trump.suit
  end

  def trump=( suit_string )
    @trump = @@suits[ suit_string ]
  end

  def trump
    @@suits.index(@trump)
  end

  def add_card( card )
    @hand.push( card )
  end

  def card_value( card )
    face = card[0].chr
    suit = card[1].chr

    if left_brower?(card) then
      suit_value = @trump.to_a.reverse.index( @trump.suit ) * MAX_CARDS_PER_SUIT
      face_value = @@face_values_trump[ face ] - 1
    elsif trump?(card) then
      suit_value = @trump.to_a.reverse.index( @trump.suit ) * MAX_CARDS_PER_SUIT
      face_value = @@face_values_trump[ face ]
    else
      suit_value = @trump.to_a.reverse.index( suit ) * MAX_CARDS_PER_SUIT
      face_value = @@face_values_regular[ face ]
    end

    suit_value + face_value
  end

  def hand
    @hand.sort {|x,y| card_value(y)<=>card_value(x) }
  end
end
