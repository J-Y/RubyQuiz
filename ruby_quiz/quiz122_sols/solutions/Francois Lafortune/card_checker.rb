#!/usr/bin/env ruby 
# rubyquiz #122
# I know, I know, this code is ugly, but I had fun and this is my first Ruby Quiz! :P

def card_type(num)
  size = num.size.to_s
  { 'AMEX' => [%r(^34|37),%r(15)],
    'Discover' => [%r(^(6011/16)),%r(16)],
    'MasterCard' => [%r(^(51|55)),%r(16)],
    'Visa' => [%r(^4),%r(13|16)]
  }.each_pair do |n,c|
    return n unless !(num.match(c[0]) && size.match(c[1]))
  end
  return 'unknown'
end

def luhn(num)
d = num.split(//)
((0..d.size).inject(0){|a,i| a += (d[i].to_i * (2-i%2)).to_s.split(//).inject(0){|r,n| r + n.to_i}} % 10).zero?
end

num = ARGV.join.delete(",")
puts "\nCard: #{card_type(num)}\nValid: #{luhn(num)}"
