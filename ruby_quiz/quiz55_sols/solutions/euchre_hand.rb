#!/usr/local/bin/ruby -w

# build a Euchre deck
cards = Array.new
%w{9 T J Q K A}.each do |face|
  %w{d c s h}.each do |suit|
    cards << face + suit
  end
end

# choose trump
puts %w{diamonds clubs spades hearts}[rand(4)]

# deal a hand
cards = cards.sort_by { rand }
puts cards[0..4]
