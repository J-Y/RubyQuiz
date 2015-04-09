#!/usr/bin/ruby -w

NUMS = %w(9 T J Q K A)
SUITS = %w(h c d s)
COLOURS = Hash[*%w(s B d R c B h R)]

def card_value(card, trump)
	num, suit = card.split('')

	value = NUMS.index(num)
	value += 10 * SUITS.index(suit)
	if num == 'J'
		value += 150 if COLOURS[suit] == COLOURS[trump]
		value += 10 if suit == trump
	elsif suit == trump
		value += 100
	end
	
	return value
end

trump = gets.chomp
tsuit = trump[0,1].downcase

puts trump
puts $stdin.readlines.sort_by { |card| -card_value(card,tsuit) }
