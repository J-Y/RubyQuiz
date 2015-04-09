class Hand
	attr :cards
	SUITS 	= %w{s h c d} # should be ordered by alternating colors
	RANKS 	= %w{9 T J Q K A} # must be ordered low to high

	def initialize(cards, trump)
		@trump_c = trump[0,1].downcase
		@complement = SUITS[SUITS.index(@trump_c) - 2]
		first_off_suit = SUITS.find{|suit|
![@trump_c,@complement].include?(suit) &&
cards.find{|card|card[1,1]==suit}}
		@suit_values = {@trump_c => 100, first_off_suit => 50, @complement =>
25}
		@cards = cards.sort_by{|card| get_val(card) * -1}.unshift(trump)
	end

	private

	def get_val(card)
		val = RANKS.index(card[0,1]) + (@suit_values[card[1,1]] ||= 0)
		return ["J#{@trump_c}", "J#{@complement}"].include?(card) ? val+500 :
val
	end
end

cards = STDIN.read.split
puts Hand.new(cards, cards.shift).cards
