@card_types = [
 ["Mastercard",/^5[1-5]\d{14}$/],
 ["Visa",/^4(\d{12}|\d{15})$/],
 ["Discover",/^6011\d{12}$/],
 ["AMEX",/^3[47]\d{13}$/],
 ["Unknown",/^\d*$/]
]

def card_type( card_number )
 card_number.gsub!( /\s/, '')
 @card_types.each do |card_type|
   return card_type[0] if card_type[1] =~ card_number
 end
 raise "Invalid characters in input"
end

def luhn( card_number )
 sum = 0
 card_number.length.downto( 1 ) do |i|
   doubled = ( i%2 + 1 ) * ( card_number[ i-1, 1 ].to_i )
   if doubled >= 10
     doubled = (doubled  % 10 ) + 1
   end
   sum += doubled
 end
 sum % 10 == 0
end

def validate( card_number )
 return card_type( card_number ), luhn( card_number )
end

p validate( ARGV.join.gsub( /\s/, '') )
