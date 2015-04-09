#!/usr/bin/env ruby -w

class Deck
 def initialize(number_of_decks)
   @cards = []

   suits = ["h","c","d","s"]
   values = [2,3,4,5,6,7,8,9,"t","j","q","k","a"]

   number_of_decks.times do
     suits.each do |suit|
       values.each do |value|
         @cards << suit + value.to_s
       end
     end
   end
   shuffle
 end

 def shuffle
   @cards = @cards.sort_by {rand}
 end

 def deal
   @cards.pop
 end

 def deal_a(card)
   # Deal a named card from the deck
   @cards.delete_at(@cards.index(card))
 end
end

class Dealer

 def initialize(deck,upcard)
   @hand = []
   @score = 0
   @hand << deck.deal_a(upcard)
   @hand << deck.deal
   @deck = deck
 end

 def bust?
   current_score > 21
 end

 def natural?
   current_score == 21 && @hand.length == 2
 end

 def current_score

   # To deal with multiple aces, sort the current hand so that the
   # aces appear as the last elements in the array.
   values = []
   @hand.each {|card| values << card[1].chr}
   not_aces = values.find_all {|v| /[^a]/=~v}
   aces = values.find_all {|v| /[a]/=~v}

   values = not_aces + aces

   # Calculate the score for this hand
   score = 0
   values.each do |value|
     if /\d/ =~ value then score += value.to_i end
     if /[t,k,j,q]/ =~ value then score += 10 end
     if /[a]/ =~ value then
       if score + 11 > 21
         score += 1
       elsif
         score += 11
       end
     end
   end
   score
 end

 def play
   until self.bust? || current_score >= 17
     card = @deck.deal
     @hand << card
   end

   if self.bust?
     "bust"
   elsif self.natural?
     "natural"
   else
     current_score
   end
 end
end

if __FILE__ == $0
 upcards = ["c2","c3","c4","c5","c6","c7","c8","c9","ct","cj","cq","ck","ca"]
 outcomes = ["bust",17,18,19,20,21,"natural"]

 no_of_games = 5000
 printf("Upcard\tBust\t17\t18\t19\t20\t21\tNatural\n")
 upcards.each do |upcard|
   results = []
   no_of_games.times {results << Dealer.new(Deck.new(8),upcard).play}

   p = []
   outcomes.each do |outcome|
     number = results.find_all {|r| r==outcome}
     p << (number.length.to_f/no_of_games)*100
   end

   printf("%s\t%5.2f%%\t%5.2f%%\t%5.2f%%\t%5.2f%%\t%5.2f%%\t%5.2f%%\t%5.2f%%\n",
          upcard,p[0],p[1],p[2],p[3],p[4],p[5],p[6])
 end
end
