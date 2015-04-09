# ccc.rb
# Checking Credit Cards

class String
 def begins_with?(str)
   temp = self.slice(0...str.length)
   temp == str
 end
end

class Array
 def collect_with_index
   self.each_with_index do |x, i|
     self[i] = yield(x, i)
   end
 end
end

class CCNumber
 #This data was taken from http://en.wikipedia.org/wiki/Credit_card_number
 TYPES = [
   Hash['type' => 'American Express',               'key' => [34, 37],                     'length' => [15]],
   Hash['type' => 'China Union Pay',                 'key' => (622126..622925).to_a, 'length' => [16]],
   Hash['type' => 'Diners Club Carte Blanche', 'key' => (300..305).to_a,          'length' => [14]],
   Hash['type' => 'Diners Club International', 'key' => [36],                          'length' => [14]],
   Hash['type' => 'Diners Club US & Canada',    'key' => [55],                           'length' => [16]],
   Hash['type' => 'Discover',                            'key' => [6011, 65],                  'length' => [16]],
   Hash['type' => 'JCB',                                    'key' => [35],                           'length' => [16]],
   Hash['type' => 'JCB',                                    'key' => [1800, 2131],               'length' => [15]],
   Hash['type' => 'Maestro',                             'key' => [5020, 5038, 6759],        'length' => [16]],
   Hash['type' => 'MasterCard',                        'key' => (51..55).to_a,               'length' => [16]],
   Hash['type' => 'Solo',                                  'key' => [6334, 6767],                'length' => [16, 18, 19]],
   Hash['type' => 'Switch',                               'key' => [4903, 4905, 4911, 4936, 564182, 633110, 6333, 6759],
                                                                                                                       'length' => [16, 18, 19]],
   Hash['type' => 'Visa',                                  'key' => [4],                             'length' => [13, 16]],
   Hash['type' => 'Visa Electron',                    'key' => [417500, 4917, 4913],   'length' => [16]]
   ]
   #number should be an array of numbers as strings e.g. ["1", "2", "3"]
 def initialize(array)
   @number = array.collect{|num| num.to_i}
 end
 def type
   names = Array.new
   TYPES.each do |company|
     company['key'].each  do |key|
       if company['length'].include?(@number.length)  and @number.join.begins_with?(key.to_s)
         names << company['type']
       end
     end
   end
   names.empty? ? ["Unknown"] : names
 end
 def valid?
   temp = @number.reverse.collect_with_index{|num, index| index%2 == 0 ? num*2 : num}
   sum = temp.collect{|num|num > 9 ? [1, num%10] : num}.flatten.inject{|s, n| s+n}
   sum%10 == 0
 end
 def process
   puts "The card type is #{self.type.join(' or ')}"
   puts "The card number is #{self.valid? ?  'valid' : 'invalid'}"
 end
end

if $0 == __FILE__
 abort "You must enter a number!" if ARGV.empty?
 CCNumber.new(ARGV.join.strip.split(//)).process
end
