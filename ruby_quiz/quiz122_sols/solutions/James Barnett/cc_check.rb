#!/usr/bin/env ruby

def type(card)
  if card =~ /\A4(\d{12}|\d{15})\Z/
    "VISA"
  elsif card =~ /\A3(4|7)\d{13}\Z/
    "AMEX"
  elsif card =~ /\A5[1-5]\d{14}\Z/
    "MasterCard"
  elsif card =~ /\A6011\d{12}\Z/
    "Discover"
  else
    "Unknown"
  end
end

def luhn_valid?(card)
  digits = card.unpack("c#{card.length}").map { |c| c.chr.to_i }
  sum = 0
  digits.each_with_index do |n, i|
    val = if i % 2 == digits.length % 2
      2 * n
    else
      n
    end

    sum += if val >= 10
      1 + (val % 10)
    else
      val
    end
  end
  sum % 10 == 0
end

def valid?(card)
  card_type = type(card)
  puts "#{card_type} - #{ (card_type != "Unknown" && luhn_valid?
(card)) ? "Valid" : "Invalid" }"
end

valid?(ARGV[0])
