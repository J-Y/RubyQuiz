#!/usr/bin/ruby -w

NUMS = %w(9 T J Q K A)
SUITS = %w(h c d s)
COLOURS = Hash[*%w(s B d R c B h R)]

def card_value(card, trump)
	num, suit = card.split('')
	
	value = Array.new
	
	value << (num == 'J' && value[3] == 1 ? 1 : 0)
	value << (num == 'J' && COLOURS[suit] == COLOURS[trump] ? 1 : 0)
	value << (suit == trump ? 1 : 0)
	value << SUITS.index(suit)
	value << NUMS.index(num)
end

trump = gets.chomp
tsuit = trump[0,1].downcase

puts trump
puts $stdin.readlines.sort_by { |card| card_value(card,tsuit) }.reverse
