module Cards
	class Value
		include Comparable
		
		attr_accessor :to_i
		@@values = []
		def initialize(int_val, short_string = int_val.to_s, long_string = int_val.to_s)
			@to_i = int_val
			@short_string = short_string
			@long_string = long_string
			@@values << self
		end
		def to_s(long = false)
			if long
				@long_string
			else
				@short_string
			end
		end
		def <=>(other)
			to_i <=> other.to_i
		end
		def self.[](index)
			@@values.find {|val| val.to_i == index || val.to_s == index || val.to_s(:long) == index } or
			Value.new(index)
		end
		def self.values
			@@values
		end
	
		Ace = Value.new(1, 'A', 'Ace')
		numbers = (2..9).map{|i| Value.new(i) } <<
			Value.new(10, 'T', '10')
		Jack = Value.new(11, 'J', 'Jack')
		Queen = Value.new(12, 'Q', 'Queen')
		King = Value.new(13, 'K', 'King')
		StandardValues = [Ace] + numbers + [Jack, Queen, King]
		Joker = Value.new(0, '?', 'Joker')
	end
	class Color
		attr_reader :val, :to_s
		@@values = []
		def initialize(to_s, val = nil)
			@val = val
			@to_s = to_s
			@@values << self
		end
		def self.values
			@@values
		end
		def self.[](index)
			@@values.find {|color| color.val == index || color.to_s == index  } or
			Color.new(index)
		end
		Black = Color.new('black', false)
		Red = Color.new('red', 'true')
	end
	class Suit
		attr_accessor :to_i
		attr_reader :color
		@@values = []
		def initialize(long_string, color = nil, short_string = long_string[0,1], int_val = 0)
			@short_string = short_string
			@long_string = long_string
			@color = color
			@to_i = int_val
			@@values << self
		end
		def self.values
			@@values
		end
		def to_s(long = false)
			if long
				@long_string
			else
				@short_string
			end
		end
		def red?
			color == Color::Red
		end
		def black?
			color == Color::Black
		end
		def self.[](index)
			@@values.find {|suit| suit.to_s == index || suit.to_s(:long) == index } or
			Suit.new(index)
		end
		Spades = Suit.new('Spades', Color::Black, 's') #"\x06"
		Clubs = Suit.new('Clubs', Color::Black, 'c') #"\x05"
		Diamonds = Suit.new('Diamonds', Color::Red, 'd') #"\x04"
		Hearts = Suit.new('Hearts', Color::Red, 'h') #"\x03"
		StandardSuits = [Spades, Clubs, Diamonds, Hearts]
	end
	class Card
		include Comparable
		
		attr_accessor :to_i
		attr_reader :value, :suit
		@@values = []
		def initialize(value, suit, to_i = 0)
			@value = value
			@suit = suit
			@to_i = to_i
			@@values << self
		end
		def self.values
			@@values
		end
		def to_s(long = nil)
			if Suit === suit
				value.to_s(long) + (long ? ' of ' : '') + suit.to_s(long)
			else
				value.to_s(long) + (suit ? (long ? " (#{suit})" : suit.to_s[0,1]) : '')
			end
		end
		def <=>(other)
			value <=> other.value
		end
		def self.[](v, s)
			@@values.find {|card| card.value == v && card.suit == s } or
			Card.new(v, s)
		end
		Joker = Card.new(Value::Joker, nil)
		RedJoker = Card.new(Value::Joker, Color::Red)
		BlackJoker = Card.new(Value::Joker, Color::Black)
	end
	
	module Deck
		def self.new
			Suit::StandardSuits.inject([]) {|deck, suit|
				deck.concat( Value::StandardValues.map{|value| Card.new(value, suit) } )
			}.extend(self)
		end
		def shuffle!
			replace(sort_by {rand})
		end
		def swap!(a, b)
			temp = self[a]
			self[a] = self[b]
			self[b] = temp
		end
	end
end

if $0 == __FILE__
	include Cards
	puts (Deck.new << Card::Joker << Card::RedJoker).shuffle!.join(' ')
	puts Value['Joker']
	puts Value[1]
	puts Value['Jack']
	puts Value[14]
	puts Suit['Spades']
	puts Suit['Digbies']
	puts Color['black']
	puts Color['pink']
	puts Value.values.join(' ')
	puts Suit.values.join(' ')
	puts Color.values.join(' ')
	puts Card.new(Value::Joker, Color['pink'])
	puts Card.values.join(' ')
end
