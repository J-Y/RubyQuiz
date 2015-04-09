#!/usr/bin/env ruby

CARDS = %w(A 2 3 4 5 6 7 8 9 10 J Q K)
DECKS = ARGV.size == 1 ? ARGV[0].to_i : 2
SUITS = 4

def hand_value(hand)
 value = 0
 # First calculate values counting aces as 11
 hand.each do |c|
   if c=='A'
     value += 11
   elsif 'JQK'.include? c
     value += 10
   else
     value += c.to_i
   end
 end
 # Then re-value aces as 1 as long as hand is bust
 hand.each do |c|
   if c=='A'
     if value>21
       value -= 10
     end
   end
 end
 value
end

def new_shute
 cards = []
 CARDS.each do |c|
   DECKS.times { SUITS.times { cards << c }}
 end
 cards
end

def odds_of(cards, v)
 count = 0
 cards.each { |c| count += 1 if c==v }
 (1.0 * count) / cards.length
end

# calc the odds of reaching result from a given hand
def calc_odds(hand, result)
 current = hand_value(hand)
 return 1.0 if current == result
 return 0.0 if current >= 17

 # Remove hand cards from full shute
 cards = new_shute
 hand.each {|c| cards.delete_at(cards.index(c))}

 odds = 0.0
 CARDS.each do |c|
   odds_of_card = odds_of(cards, c)
   if odds_of_card > 0.0
     hand.push c
     odds_of_result = calc_odds(hand, result)
     odds += odds_of_card * odds_of_result
     hand.pop
   end
 end

 return odds
end

puts "Odds for each dealer outcome based on initial upcard (#{DECKS} deck game)"

puts "     17     18     19     20     21    BUST"
CARDS.each do |c|
 odds = {}
 bust = 100.0
 (17..21).each do |r|
   odds[r] = calc_odds([c], r) * 100.0
   bust -= odds[r]
 end
 printf "%2s  %5.02f%% %5.02f%% %5.02f%% %5.02f%% %5.02f%% %5.02f%%\n", c, odds[17], odds[18], odds[19], odds[20], odds[21], bust
end
