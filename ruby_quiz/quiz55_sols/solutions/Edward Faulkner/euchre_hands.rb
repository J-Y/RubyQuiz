SUITS = %w{d c h s}.map {|s| s[0]}
CARDS = %w{A K Q J T 9}.map {|c| c[0]}

trump,hand = STDIN.readline, STDIN.readlines

puts trump
trump = SUITS.index(trump.downcase[0])

# If the suit after the trump suit is missing, we swap it with the
# other suit of the same color.  This ensures that we always have a
# correct color alternation when possible.
unless hand.find {|card| card[1] == SUITS[(trump+1)%4]}
  tmp = SUITS[(trump+1)%4]
  SUITS[(trump+1)%4] = SUITS[(trump+3)%4]
  SUITS[(trump+3)%4] = tmp
end

hand.map { |card| 
  suit = (SUITS.index(card[1]) - trump)%4
  num = CARDS.index(card[0])
  if num==3 && suit==2
    suit,num = 0,-1             # Left bower
  elsif num==3 && suit==0
    num = -2                    # Right bower
  end
  [suit,num,card.chomp]
}.sort.each{|c| puts "#{c[2]}\n" }

