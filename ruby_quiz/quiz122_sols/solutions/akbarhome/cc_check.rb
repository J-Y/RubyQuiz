#!/usr/bin/ruby

credit_card_number = ARGV.join

case
when (credit_card_number=~/^(34|37)\d{13}$/): print 'AMEX '
when (credit_card_number=~/^6011\d{12}$/): print 'Discover '
when (credit_card_number=~/^5[1-5]\d{14}$/): print 'MasterCard '
when (credit_card_number=~/^4(\d{12}|\d{15})$/): print 'Visa '
else print 'Unknown '
end

i = 0
luhl_number = ''
credit_card_number.reverse.each_byte {|char|
  if (i%2==1) then
    char = (char.chr.to_i * 2).to_s
  else
    char = char.chr
  end
  luhl_number = char + luhl_number
  i += 1
}

sum_total = 0

luhl_number.each_byte {|char|
  sum_total += char.chr.to_i
}

if (sum_total%10==0) then
  print "Valid\n"
else
  print "Invalid\n"
end
