#card_check.rb

def check_type(number)
 #Returns a string representing the type of card if the length and
leading
 #  digits are valid.  Otherwise returns "Unknown".
 valid = {
   /^(34|37)/ => [15,"AMEX"],
   /^6011/ => [16,"Discover"],
   /^(51|52|53|54|55)/ => [16,"MasterCard"],
   /^4/ => [13,16,"Visa"]
 }
 number.gsub!(/ /,"")
 valid.each_key do |i|
   if number =~ i
     return valid[i][-1] if valid[i].include? number.length
   end
 end
 return "Unknown"
end

def luhn(number)
 # Returns "valid" if the number passes the Luhn algorihm criteria. Returns
 #   "invalid" if the algorithm fails.
 number = number.gsub(/ /,"").split(//).reverse
 new_number = ""
 number.each_index do |i|
   new_number << (number[i].to_i*2).to_s if (i+1) % 2 == 0
   new_number << number[i] if (i+1) % 2 == 1
 end
 new_number = new_number.split(//)
 sum = 0
 new_number.each_index { |i| sum += new_number[i].to_i }
 return "valid" if sum % 10 == 0 unless number.length == 0
 return "invalid"
end

def validate_card(number)
 puts "Type:   #{check_type(number)}"
 puts "Status: #{luhn(number)}"
end

validate_card(ARGV.join("")) if __FILE__ == $0
