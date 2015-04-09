#!/usr/bin/env ruby

# Solution to Ruby Quiz #151 (see http://www.rubyquiz.com/quiz151.html)
# by Pawel Radecki (pawel.j.radecki@gmail.com).

COLOURS_IN_DECK = 4
SIMULATIONS_NO = 1000

class Array
   def shuffle
       sort_by { rand }
   end
end

class Card

   attr_reader :face

   @@blackjack_values = { "A" => [1,11] , "K" => 10, "Q" => 10, "J" => 10,
           "10" => 10, "9" => 9, "8" => 8, "7" => 7, "6" => 6, "5" => 5, "4" => 4,
           "3" => 3, "2" => 2}

   @@list = ["A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2" ]

   def initialize(face)
       if @@blackjack_values.keys.include? face
           @face=face
       else
           raise Exception.new("Can't initialize card with face: "+face)
       end
   end

   def blackjack_value
       @@blackjack_values[@face]
   end

   def best_blackjack_value(score)
       if (self.blackjack_value.respond_to? :pop)
           if (score>10)
               self.blackjack_value[0]
           else
               self.blackjack_value[1]
           end
       else
           self.blackjack_value
       end
   end

   def self.faces
       @@blackjack_values.keys
   end

   def self.list
       @@list
   end

   def to_s
       return "#{@face}"
   end

   def inspect
       return "#{@face}"
   end
end

#one or more decks
class DeckSet

   #new shuffled deck
   def initialize (decks_no=2)
       @cards = []

       (decks_no*COLOURS_IN_DECK).times do
           Card.faces.shuffle.each {|c| @cards << Card.new(c)}
       end
   end

   def draw
       @cards.pop
   end

   def empty?
       @cards.empty?
   end
end


USAGE = <<ENDUSAGE
Usage:
  black_jack_dealer_chances.rb [-u <upcard>] [-d <decks_no>]
  -u upcard: {#{Card.list.join(", ")}}
  -d number of decks used

  Calculates percentage chances of a black jack dealer reaching each possible outcome.
  Upcard may be given, number of the decks may be configured.

  Example: black_jack_dealer_chances.rb -u "Q" -d 5
ENDUSAGE

if ARGV.length>4
   puts USAGE
   exit
end

upcard = nil
decks_no = 2

if ARGV.include?("-u")
   upcard = ARGV[ARGV.index("-u")+1]
   if (upcard.nil? || !Card.faces.include?(upcard))
       puts USAGE
       exit
   end
   ARGV.delete("-u")
   ARGV.delete(upcard)
end

if ARGV.include?("-d")
   decks_no = ARGV[ARGV.index("-d")+1]
   if (decks_no.nil?)
       puts USAGE
           exit
   end
   ARGV.delete("-d")
   ARGV.delete(decks_no)
end

histogram = Hash.new 0
sum = Hash.new 0
probability = []

SIMULATIONS_NO.times do
   decks = DeckSet.new(decks_no.to_i)
   while (!decks.empty?)
       score = 0; hand = []
       while score<17
           hand << card=decks.draw
           score+=card.best_blackjack_value(score)

           if score==21 && hand.size==2
               if $DEBUG
                   print "hand: "
                   p hand
                   print "score: "
                   p score
                   puts
               end
               sum[hand.first.face]+=1
               histogram[[hand.first.face,"natural"]]+=1
               break
           elsif score>21
               if $DEBUG
                   print "hand: "
                   p hand
                   print "score: "
                   p score
                   puts
               end
               sum[hand.first.face]+=1
               histogram[[hand.first.face,"bust"]]+=1
               break
           elsif (17..21).include? score
               if $DEBUG
                   print "hand: "
                   p hand
                   print "score: "
                   p score
                   puts
               end
               sum[hand.first.face]+=1
               histogram[[hand.first.face,score]]+=1
               break
           elsif decks.empty?
               break
           end

       end
   end
end

histogram.keys.each { |el| probability << [el,histogram[el].to_f/sum[el.first]].flatten  }
probability.sort! { |x,y| x.first != y.first ? Card.list.index(x.first) <=> Card.list.index(y.first) : y.last <=> x.last}

card = nil
probability.each do |el|
   if (upcard==nil || el.first==upcard)
       if card!=el.first
           card=el.first
           puts "#{el.first}:"
       end
           printf("%8s -> %2.0f%% \n", el[1], el.last*100)
   end
end

exit
