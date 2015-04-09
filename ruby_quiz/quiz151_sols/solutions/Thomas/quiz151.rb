#!/usr/bin/env ruby
# Author::      Thomas Link (micathom AT gmail com)
# Created::     2008-01-05.

class Quiz151b
   LABELS = ['bust', 'natural', *(17..21).to_a]
   NAMES  = ['A', *(2..10).to_a] << 'B' << 'D' << 'K'
   CARDS  = (1..10).to_a + [10] * 3

   class << self
       def run(sample=10000, decks=2)
           puts '    ' + LABELS.map {|k| '%-7s' % k}.join(' ')
           13.times do |upcard|
               puts Quiz151b.new(upcard, decks).run(sample)
           end
       end
   end

   def initialize(upcard, decks)
       @upcard = upcard
       @cards  = CARDS * (4 * decks)
       @hands  = []
   end

   def run(sample)
       sample.times {@hands << deal(@upcard)}
       self
   end

   def to_s
       total = @hands.size
       acc   = Hash.new(0)
       @hands.each do |sum, hand|
           label = sum > 21 ? 'bust' :
               sum == 21 && hand.size == 2 ? 'natural' :
               sum
           acc[label] += 1
       end
       '%02s: %s' % [
           NAMES[@upcard],
           LABELS.map {|k| '%6.2f%%' % (100.0 * acc[k] / total)}.join(' ')
       ]
   end

   def deal(idx)
       cards = @cards.dup
       hand  = []
       sum   = 0
       loop do
           hand << cards.delete_at(idx)
           sum = count(hand)
           return [sum, hand] if sum >= 17
           idx = rand(cards.size)
       end
   end

   def count(hand)
       sum  = 0
       tidx = 21 - hand.size - 10
       hand.dup.sort.reverse.each_with_index do |c, i|
           sum += c == 1 && sum <= tidx + i ? 11 : c
       end
       return sum
   end

end


if __FILE__ == $0
   case ARGV[0]
   when '-h', '--help'
       puts "#$0 [DEALS=10000] [DECKS=2]"
   else
       Quiz151b.run(*ARGV.map {|e| e.to_i})
   end
end
