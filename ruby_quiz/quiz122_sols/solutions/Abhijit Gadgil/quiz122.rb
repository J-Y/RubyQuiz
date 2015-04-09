#!/usr/bin/ruby

def is_luhn? cardno

 digits = cardno.split(//).reverse!

 sum = ''
 digits.each_index do |i|
   if i%2 == 0
     sum << digits[i]
   else
     sum <<  (2 * digits[i].to_i).to_s
   end

 end
 s1 = 0
 sum.split(//).inject(s1) { |s1, v| s1 += v.to_i }
 if s1 % 10 == 0
   return "Valid"
 else
   return "InValid"
 end

end


if __FILE__ == $0:

 abort("Usage: ruby quiz122.rb #CARDNO") if ARGV.length != 1

 cardno = ARGV[0].gsub(/[^0-9]/, '')

 is_luhn? cardno

 print "card number \"#{cardno}\" is "
 case cardno.length
 when 13
   if cardno.match(/^4/)
     print "Visa : "
   else
     print "Unknown : "
   end
   puts is_luhn?(cardno)

 when 14
   if cardno.match(/(^30[0-2][0-9])|(^30[4-5][0-9])|(^36)|(^38(1[5-9]|[2-9]))/)
     print "Diners : "
   else
     print "Unknown : "
   end

 when 15
   if cardno.match(/^3(4|7)/)
     print "Amex : "
   else
     print "Unknown : "
   end

 when 16
   if cardno.match(/^6011/)
     print "Discover : "
   elsif cardno.match(/^4/)
     print "Visa : "
   elsif cardno.match(/^5[1-5]/)
     print "MasterCard : "
   elsif cardno.match(/^35(2[8-9]|[3-8][0-9])/)
     print "JCB : "
   else
     print "Unknown : "
   end

 else
   print "Unknown : "

 end

 puts  is_luhn?(cardno) + " CC "

end
