class Card
	@@values = {'A' => :ace, 'K' => :king, 'Q' => :queen, 'J' => :jack,
'T' => :ten, '9' => :nine}
	@@value_values = {:ace => 6, :king => 5, :queen => 4, :jack => 3, :ten
=> 2, :nine => 1}
	@@suits = {'h' => :hearts, 'd' => :diamonds, 'c' => :clubs, 's' =>
:spades}
	@@suit_values = {:hearts => 2, :diamonds => -2, :clubs => 1, :spades
=> -1}

	# The suit_values is used to compactly calculate the order suits
should be sorted in

	def initialize(string = "Jh", trump = :hearts)
		@suit = :hearts
		@value = :ace
		@trump = trump
		if string
			self.parse(string)
		end
	end

	def parse(string)
		cardarray = string.upcase.scan(/[AKQJT9][HDCS]/)
		if cardarray.length > 0
			@value = @@values[cardarray[0][0,1]]
			@suit = @@suits[(cardarray[0][1,1]).downcase]
		end
	end

	def rank_value
		case @suit
			when @trump
				return @value == :jack ? 40 : (@@value_values[@value] + 30)
			when @@suit_values.index(@@suit_values[@trump] * -1)
			# True when card is of the trump's suit's colour companion
				return @value == :jack ? 39 : (@@value_values[@value] + 10)
			when @@suit_values.index((@@suit_values[@trump] % 2) + 1)
			# Triggers for clubs if trump is red or hearts if trump is black
				return @@value_values[@value] + 20
			else
			# The last remaining suit comes last
				return @@value_values[@value]
		end
	end

	def <=>(other)
		self.rank_value <=> other.rank_value
	end

	def printable
		@@values.index(@value) + @@suits.index(@suit)
	end

	include Comparable

	attr_accessor :trump, :value, :suit
end

class Hand
	def initialize(trump = :hearts, *cards)
		@cards = Array.new
		@trump = trump
		cards.each do |cs|
			@cards << Card.new(cs, trump)
		end
		@cards.sort!
	end

	def add_card(card)
		@cards << Card.new(card, @trump)
	end

	def display
		@cards.sort!
		@cards.reverse.each do |card|
			puts card.printable
		end
	end

	def inspect
		handstring = String.new
		@cards.each do |card|
			handstring << card.printable << ', '
		end
		handstring.chop!
		handstring.chop!
	end

	def trump=(newtrump)
		@trump = newtrump
		@cards.each {|c| c.trump = newtrump}
	end

	attr_accessor :cards
	attr_reader :trump
end

if __FILE__ == $0

	until (trumpline = readline()) != ""
	end

	case trumpline.downcase[0,1]
		when 'h'
			trump = :hearts
		when 'd'
			trump = :diamonds
		when 'c'
			trump = :clubs
		when 's'
			trump = :spades
		else
			raise StandardError, "Bad Input"
	end

	h = Hand.new(trump)

	5.times do |t|
		cardline = readline()
		h.add_card(cardline)
	end
	
	puts trump.to_s.capitalize
	h.display

end
