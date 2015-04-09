# Credit Card Validation
# Ruby Quiz #122 - http://www.rubyquiz.com/quiz122.html
# By Mike Moore - http://blowmage.com/

require 'yaml'

class CreditCard
 def CreditCard.luhn(cc)
   multi = 1
   nums = cc.gsub(/\D/, '').reverse.split('').collect do |num|
     num = num.to_i * (multi = (multi == 1) ? 2 : 1)
   end
   total = 0
   nums.join.split('').each do |num|
     total += num.to_i
   end
   total
 end

 def CreditCard.valid?(cc)
   (CreditCard.luhn(cc) % 10) == 0
 end

 def CreditCard.type(cc)
   cc.gsub!(/\D/, '')
   YAML::load(open('ccard.yaml')).each do |card, rule|
     rule['starts'].each do |start|
       if (cc.index(start.to_s) == 0)
         return card if rule['sizes'].index(cc.size)
       end
     end
   end
   'Unknown'
 end

 def initialize(cc)
   @number = cc.gsub(/\D/, '')
 end

 def number
   @number
 end

 def number=(cc)
   @number = cc.gsub(/\D/, '')
 end

 def valid?
   CreditCard.valid? @number
 end

 def type
   CreditCard.type @number
 end
end

if __FILE__ == $0
 cc = CreditCard.new ARGV.join
 puts "You entered the following credit card number: #{cc.number}"
 puts "The number is for a #{cc.type} credit card"
 puts "The number is #{cc.valid? ? 'Valid' : 'Not Valid'}"
end
