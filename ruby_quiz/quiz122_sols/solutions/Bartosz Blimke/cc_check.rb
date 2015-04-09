class CreditCardNumberValidator

   CARD_TYPE =  {
       :amex => 'AMEX',
       :discover => 'DISCOVER',
       :master_card => 'MASTER CARD',
       :visa => 'VISA',
       :unknown =>  'UNKNOWN'
   }

   CARD_NUMBER_PATTERN = {
       :amex => /^3[4|7][0-9]{13}$/,
       :discover => /^6011[0-9]{12}$/,
       :master_card => /^5[1-5][0-9]{14}$/,
       :visa => /^4[0-9]{12}$|^4[0-9]{15}$/
   }


   def self.card_type(card_num)
       CARD_NUMBER_PATTERN.each do |t, p|
           return CARD_TYPE[t] if card_num =~ p
       end
       CARD_TYPE[:unknown]
   end

   def self.valid?(card_num)
       sum = 0
       card_num.to_s.reverse.scan(/./).each_with_index do |digit, index|
         digit = digit.to_i * (1 + (index % 2))
         sum+=digit/10 + digit%10;
       end
       sum % 10 == 0
   end
end

abort "Usage: #{$0} number" unless  ARGV.length > 0
card_num = ARGV.join.to_i
puts "Number: #{card_num}"
puts 'Type: ' + CreditCardNumberValidator.card_type(card_num)
puts 'Validation: ' + (CreditCardNumberValidator.valid?(card_num)?'Valid':'Invalid')
