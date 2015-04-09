#!/usr/bin/ruby
# vim: sts=2 sw=2 expandtab nu tw=0:

class String
 def to_rgx
   Regexp.new self
 end

 def ccc
   Checker.new{
     amex [34,37], 15
     discover 6011, 16
     master 50..55, 16
     visa 4, [13,16]
     jcb 3528..3589, 16
   }.check self
 end
end

class Checker
 UsageException = Class.new Exception
 def initialize &blk
   @cards = {}
   instance_eval &blk
 end

 def check str
   s = str.gsub(/\s/,"")
   @cards.each do
     |card, check_values|
     return [ luhn( s ), card.to_s.capitalize ] if
       check_values.first === s && check_values.last.include?( s.length )
   end
   [ nil, "Unknown" ]
 end

 def luhn s
   sum = 0
   s.split(//).reverse.each_with_index{
     | digit, idx |
     sum += (idx%2).succ * digit.to_i
   }
   (sum % 10).zero? ? " Valid" : "n Invalid"
 end
 # This is one of the rare examples where
 # the method_missing parametes are not
 # id, *args, &blk, trust me I know what
 # I am doing ;)
 def method_missing credit_card_name, regs, lens
     raise UsageException, "#{card_name} defined twice" if
       @cards[credit_card_name]
     ### Unifying Integer, Array and Range parameters
     lens = [lens] if Integer === lens
     lens = lens.to_a
     ### Genereating regular expressions
     regs = [regs] if Integer === regs
     regs = regs.map{ |r| "^#{r}" }.join("|").to_rgx
     @cards[credit_card_name] = [ regs, lens ]
 end
end

ARGV.each do
 | number |
 puts "Card with number #{number} is a%s %s card" %
   number.ccc

end # ARGV.each do
