#!ruby -w

class Card
  SUITS = "cdhs"
  FACES = "L23456789TJQKA"
  SUIT_LOOKUP = {
    'c' => 0,
    'd' => 1,
    'h' => 2,
    's' => 3,
    'C' => 0,
    'D' => 1,
    'H' => 2,
    'S' => 3,
  }
  FACE_VALUES = {
    'L' =>  1,   # this is a magic low ace
    '2' =>  2,
    '3' =>  3,
    '4' =>  4,
    '5' =>  5,
    '6' =>  6,
    '7' =>  7,
    '8' =>  8,
    '9' =>  9,
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14,
  }

  def Card.face_value(face)
    if (face)
      FACE_VALUES[face] - 1
    else
      nil
    end
  end

  def build_from_string(card)
    build_from_face_suit(card[0,1], card[1,1])
  end

  def build_from_value(value)
    @value = value
    @suit  = value / FACES.size()
    @face  = (value % FACES.size())
  end

  def build_from_face_suit(face, suit)
    @face  = Card::face_value(face)
    @suit  = SUIT_LOOKUP[suit]
    @value = (@suit * FACES.size()) + (@face - 1)
  end

  def build_from_face_suit_values(face, suit)
    build_from_value((face - 1) + (suit * FACES.size()))
  end

  # got a little carried away with this constructor ;-)
  def initialize(*value)
    if (value.size == 1)
      if (value[0].respond_to?(:to_str))
        build_from_string(value[0])
      elsif (value[0].respond_to?(:to_int))
        build_from_value(value[0])
      end
    elsif (value.size == 2)
      if (value[0].respond_to?(:to_str) &&
          value[1].respond_to?(:to_str))
        build_from_face_suit(value[0], value[1])
      elsif (value[0].respond_to?(:to_int) &&
             value[1].respond_to?(:to_int))
        build_from_face_suit_values(value[0], value[1])
      end
    end
  end

  attr_reader :suit, :face, :value

  def to_s
    FACES[@face].chr + SUITS[@suit].chr
  end
end

class Deck
  def shuffle
    deck_size = @cards.size
    (deck_size * 2).times do
      pos1, pos2 = rand(deck_size), rand(deck_size)
      @cards[pos1], @cards[pos2] = @cards[pos2], @cards[pos1]
    end
  end

  def initialize
    @cards = []
    Card::SUITS.each_byte do |suit|
      # careful not to double include the aces...
      Card::FACES[1..-1].each_byte do |face|
        @cards.push(Card.new(face.chr, suit.chr))
      end
    end
    shuffle()
  end

  def deal
    @cards.pop
  end

  def empty?
    @cards.empty?
  end
end

class Hand
  def initialize(cards = [])
    if (cards.respond_to?(:to_str))
      @hand = cards.scan(/\S\S/).map { |str| Card.new(str) }
    else
      @hand = cards
    end
  end
  attr_reader :hand

  def face_values
    @hand.map { |c| c.face }
  end

  def by_suit
    Hand.new(@hand.sort_by { |c| [c.suit, c.face] }.reverse)
  end

  def by_face
    Hand.new(@hand.sort_by { |c| [c.face, c.suit] }.reverse)
  end

  def =~ (re)
    re.match(@hand.join(' '))
  end

  def arrange_hand(md)
      hand = if (md.respond_to?(:to_str))
        md
      else
        md[0] + ' ' + md.pre_match + md.post_match
      end
      hand.gsub!(/\s+/, ' ')
      hand.gsub(/\s+$/,'')
  end

  def royal_flush?
    if (md = (by_suit =~ /A(.) K\1 Q\1 J\1 T\1/))
      [[10], arrange_hand(md)]
    else
      false
    end
  end

  def delta_transform(use_suit = false)
    aces = @hand.select { |c| c.face == Card::face_value('A') }
    aces.map! { |c| Card.new(1,c.suit) }

    base = if (use_suit)
      (@hand + aces).sort_by { |c| [c.suit, c.face] }.reverse
    else
      (@hand + aces).sort_by { |c| [c.face, c.suit] }.reverse
    end

    result = base.inject(['',nil]) do |(delta_hand, prev_card), card|
      if (prev_card)
        delta = prev_card - card.face
      else
        delta = 0
      end
      # does not really matter for my needs
      delta = 'x' if (delta > 9 || delta < 0)
      delta_hand += delta.to_s + card.to_s + ' '
      [delta_hand, card.face]
    end

    # we just want the delta transform, not the last cards face too
    result[0].chop
  end

  def fix_low_ace_display(arranged_hand)
    # remove card deltas (this routine is only used for straights)
    arranged_hand.gsub!(/\S(\S\S)\s*/, "\\1 ")

    # Fix "low aces"
    arranged_hand.gsub!(/L(\S)/, "A\\1")

    # Remove duplicate aces (this will not work if you have
    # multiple decks or wild cards)
    arranged_hand.gsub!(/((A\S).*)\2/, "\\1")

    # cleanup white space
    arranged_hand.gsub!(/\s+/, ' ')
    # careful to use gsub as gsub! can return nil here
    arranged_hand.gsub(/\s+$/, '')
  end

  def straight_flush?
    if (md = (/.(.)(.)(?: 1.\2){4}/.match(delta_transform(true))))
      high_card = Card::face_value(md[1])
      arranged_hand = fix_low_ace_display(md[0] + ' ' +
          md.pre_match + ' ' + md.post_match)
      [[9, high_card], arranged_hand]
    else
      false
    end
  end

  def four_of_a_kind?
    if (md = (by_face =~ /(.). \1. \1. \1./))
      # get kicker
      (md.pre_match + md.post_match).match(/(\S)/)
      [
        [8, Card::face_value(md[1]), Card::face_value($1)],
        arrange_hand(md)
      ]
    else
      false
    end
  end

  def full_house?
    if (md = (by_face =~ /(.). \1. \1. (.*)(.). \3./))
      arranged_hand = arrange_hand(md[0] + ' ' +
          md.pre_match + ' ' + md[2] + ' ' + md.post_match)
      [
        [7, Card::face_value(md[1]), Card::face_value(md[3])],
        arranged_hand
      ]
    elsif (md = (by_face =~ /((.). \2.) (.*)((.). \5. \5.)/))
      arranged_hand = arrange_hand(md[4] + ' '  + md[1] + ' ' +
          md.pre_match + ' ' + md[3] + ' ' + md.post_match)
      [
        [7, Card::face_value(md[5]), Card::face_value(md[2])],
        arranged_hand
      ]
    else
      false
    end
  end

  def flush?
    if (md = (by_suit =~ /(.)(.) (.)\2 (.)\2 (.)\2 (.)\2/))
      [
        [
          6,
          Card::face_value(md[1]),
          *(md[3..6].map { |f| Card::face_value(f) })
        ],
        arrange_hand(md)
      ]
    else
      false
    end
  end

  def straight?
    result = false
    if hand.size > 5
      transform = delta_transform
      # note we can have more than one delta 0 that we
      # need to shuffle to the back of the hand
      until transform.match(/^\S{3}( [1-9x]\S\S)+( 0\S\S)*$/) do
        transform.gsub!(/(\s0\S\S)(.*)/, "\\2\\1")
      end
      if (md = (/.(.). 1.. 1.. 1.. 1../.match(transform)))
        high_card = Card::face_value(md[1])
        arranged_hand = fix_low_ace_display(md[0] + ' ' +
            md.pre_match + ' ' + md.post_match)
        result = [[5, high_card], arranged_hand]
      end
    end
  end

  def three_of_a_kind?
    if (md = (by_face =~ /(.). \1. \1./))
      # get kicker
      arranged_hand = arrange_hand(md)
      arranged_hand.match(/(?:\S\S ){3}(\S)\S (\S)/)
      [
        [
          4,
          Card::face_value(md[1]),
          Card::face_value($1),
          Card::face_value($2)
        ],
        arranged_hand
      ]
    else
      false
    end
  end

  def two_pair?
    if (md = (by_face =~ /(.). \1.(.*) (.). \3./))
      # get kicker
      arranged_hand = arrange_hand(md[0] + ' ' +
          md.pre_match + ' ' + md[2] + ' ' + md.post_match)
      arranged_hand.match(/(?:\S\S ){4}(\S)/)
      [
        [
          3,
          Card::face_value(md[1]),
          Card::face_value(md[3]),
          Card::face_value($1)
        ],
        arranged_hand
      ]
    else
      false
    end
  end

  def pair?
    if (md = (by_face =~ /(.). \1./))
      # get kicker
      arranged_hand = arrange_hand(md)
      arranged_hand.match(/(?:\S\S ){2}(\S)\S\s+(\S)\S\s+(\S)/)
      [
        [
          2,
          Card::face_value(md[1]),
          Card::face_value($1),
          Card::face_value($2),
          Card::face_value($3)
        ],
        arranged_hand
      ]
    else
      false
    end
  end

  def highest_card?
    result = by_face
    [[1, *result.face_values[0..4]], result.hand.join(' ')]
  end

  OPS = [
    ['Royal Flush',     :royal_flush? ],
    ['Straight Flush',  :straight_flush? ],
    ['Four of a kind',  :four_of_a_kind? ],
    ['Full house',      :full_house? ],
    ['Flush',           :flush? ],
    ['Straight',        :straight? ],
    ['Three of a kind', :three_of_a_kind?],
    ['Two pair',        :two_pair? ],
    ['Pair',            :pair? ],
    ['Highest Card',    :highest_card? ],
  ]

  def hand_rating
    OPS.map { |op|
      (method(op[1]).call()) ? op[0] : false
    }.find { |v| v }
  end

  def score
    OPS.map { |op|
      method(op[1]).call()
    }.find([0]) { |score| score }
  end

  def take_card(card)
    @hand.push(card)
  end

  def arranged_hand
    score[1] + " (#{hand_rating})"
  end

  def just_cards
    @hand.join(" ")
  end

  def to_s
    just_cards + " (" + hand_rating + ")"
  end
end

### original code by Patrick Hurley ###
#  class Player
#    def initialize(name, deck)
#      @name = name
#      @hand = Hand.new
#      2.times { @hand.take_card(deck.deal()) }
#      @folded = false
#    end
#  
#    def folded?
#      @folded
#    end
#  
#    def take_card(card)
#      @hand.take_card(card)
#    end
#  
#    def fold?(players)
#      unless (folded?)
#        if (players)
#          folded_count = players.inject(0) { |count, p|
#            (p.folded?) ? count + 1 : count
#          }
#          @folded = rand(players.size - folded_count) > (folded_count)
#        else
#          @folded = (rand(10) <= 1)
#        end
#      end
#      folded?
#  
#    end
#  
#    def score
#      (folded?) ? [[0]] : @hand.score
#    end
#  
#    def arranged_hand
#      @name + ' ' +
#      if (folded?)
#        @hand.just_cards + ' (folded)'
#      else
#        @hand.arranged_hand
#      end
#    end
#  
#    def to_s
#      @name + ' ' +
#      if (folded?)
#        @hand.just_cards + ' (folded)'
#      else
#        @hand.to_s
#      end
#    end
#  
#    def <=>(other)
#      score <=> other.score
#    end
#  end
#  
#  class TexasHoldEm
#    def initialize(player_count)
#      @deck = Deck.new
#      @common_cards = Array.new(5) { @deck.deal }
#      @players = (1..player_count).inject([]) { |players, num|
#        players << Player.new("Player #{num}", @deck)
#      }
#    end
#  
#    def game_over?
#      @common_cards.empty?
#    end
#  
#    def play_round
#      unless game_over?
#        card = @common_cards.pop
#        @players.each do |p|
#          unless p.fold?(@players)
#            p.take_card(card)
#          end
#        end
#      end
#  
#      game_over?
#    end
#  
#    def rank_players!
#      @players = @players.sort.reverse
#    end
#  
#    def arranged_players
#      @players.inject('') { |result, player|
#        result += player.arranged_hand + "\n"
#      }
#    end
#  
#    def to_s
#      @players.join("\n")
#    end
#  end
#  
#  if __FILE__ == $0
#    srand
#  
#    game = TexasHoldEm.new(5)
#    round = 1
#    until game.game_over?
#      puts "\nRound #{round}"
#      puts game
#      game.play_round
#      round += 1
#    end
#    puts "\nRound #{round}"
#    puts game
#  
#    game.rank_players!
#    puts "\nFinal Ranking"
#    puts game.arranged_players
#  end

### code by JEG2 ###
if __FILE__ == $0
	best = nil
	results = []
	
	ARGF.each_line do |line|
		if line.length < 20                                # they folded
			results << line.chomp
		else
			hand            = Hand.new(line)               # rank hand
			name            = hand.hand_rating
			score, arranged = hand.score
			
			if best.nil? or (score[0] <=> best[0]) == 1    # track best
				best = [score[0], results.size]
			end

			results << "#{arranged} #{name}"
		end
	end
	
	# show results
	results.each_with_index do |e, index|
		puts(if index == best[1] then "#{e} (winner)" else e end)
	end
end
