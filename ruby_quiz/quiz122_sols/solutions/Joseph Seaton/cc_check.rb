BCTYPES = {
   [[34,37],[15]]     => "AMEX",
   [[6011],[16]]      => "Discoverer",
   [(51..57).to_a,16] => "MasterCard",
   [[4],[13,16]]      => "Visa"}

def ctype(num)
   BCTYPES.each { |n,t| n[0].each { |s|
       return t if num.grep(/^#{s}/).any? && n[1].include?(num.length)
   } }
   "Unknown"
end

def luhncheck(num)
   e = false
   num.split(//).reverse.collect { |a| e=!e
       a.to_i*(e ? 1:2)
   }.join.split(//).inject(0) {|a,b| a+b.to_i} % 10 == 0 ? "Valid" : "Invalid"
end

card = ARGV.join.gsub(/ /, '')
if card == ""
   puts "Usage: #{$0} <card number>"
else
   puts ctype(card)
   puts luhncheck(card)
end
