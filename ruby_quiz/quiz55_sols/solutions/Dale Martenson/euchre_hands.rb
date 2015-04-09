require 'euchre'

# choose trump
puts %w{Diamonds Clubs Spades Hearts}[rand(4)]

ed = EuchreDeck.new
ed.shuffle
5.times{ puts ed.deal }

And the sort program as:

require 'euchre'

eh = EuchreHand.new

eh.trump = gets.strip

while card = gets
  eh.add_card( card.strip )
end

puts eh.trump
puts eh.hand
