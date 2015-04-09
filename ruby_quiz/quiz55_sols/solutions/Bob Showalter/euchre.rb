#!/usr/local/bin/ruby -w

# Euchre hand sorter

CARDS = %w(A K Q J T 9)
suits = %w(Spades Hearts Clubs Diamonds)

# read and check input data
trump = gets.chomp
raise "Invalid Trump Suit" unless suits.include? trump
hand = []
5.times do
  card = gets.chomp
  raise "Invalid card #{card}" unless
    card.length == 2 &&
    CARDS.include?(card[0,1]) &&
    suits.find { |suit| suit[0,1].downcase == card[1,1] }
  raise "Duplicate card #{card}" if hand.include? card
  hand << card
end

# rotate trump suit to front
suits.push(suits.shift) while suits.first != trump

# if hand is void in second suit, swap second and fourth
# (this keeps output in alternating colors)
unless hand.find { |card| card[1,1] == suits[1][0,1].downcase }
  suits[1], suits[3] = suits[3], suits[1]
end

# generate a sort order
deck = []
suits.each do |suit|
  CARDS.each do |card|
    deck << card + suit[0,1].downcase
  end
end

# move bowers to front
deck.insert(0, deck.delete_at(3))
deck.insert(1, deck.delete_at(15))

# output sorted hand (n.b. Array#& (intersection) seemed to work, but
# is the order guaranteed?)
puts trump
puts deck.select { |card| hand.include? card }
