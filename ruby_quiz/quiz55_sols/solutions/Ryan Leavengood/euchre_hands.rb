class String
  def to_suit
    self[0..0].downcase
  end
end

class EuchreSort
  # These represent preferred sorting order
  SUITS = %w{Diamonds Clubs Hearts Spades} # Alphabetical, then by color
  CARDS = %w{A K Q J T 9} # Highest to lowest

  def initialize(trump)
    @trump = trump
    trump_index = SUITS.index(trump)
    raise "Invalid trump suit: #{trump}" unless trump_index
    @right_bower = "J#{trump.to_suit}"
    # The ordering used in SUITS ensures this works
    @left_bower = "J#{SUITS[(trump_index+2)%4].to_suit}"
    # Apply weights to suits starting from the trump, wrapping
    # around as needed
    @suit_weights = {}
    weight = 10
    trump_index.upto(trump_index+3) do |i|
      @suit_weights[SUITS[i%4].to_suit] = weight
      weight += 10
    end
  end

  def sort(hand)
    weights = {}
    hand.each do |card|
      raise "Invalid card: #{card}" if card !~ /\A[#{CARDS.join}]{1}[dchs]{1}\z/
      weights[card] =
        case card
        when @right_bower: 0
        when @left_bower: 1
        else
          @suit_weights[card[1..1]] + CARDS.index(card[0..0])
        end
    end
    hand.sort_by {|c| weights[c]}
  end
end

if $0 == __FILE__
  hand = STDIN.collect {|i|i.chomp}
  trump = hand.shift
  es = EuchreSort.new(trump)
  puts trump
  puts es.sort(hand)
end
