#!/usr/bin/env ruby -wKU

# Some utility functions first
require 'enumerator'
module Enumerable
  # Maps n-at-a-time (n = arity of given block) and collects the results
  def mapn(&b)
    r = []
    each_slice(b.arity) {|*args| r << b.call(*args) }
    r
  end

  def sum; inject(0){|s, i| s + i} end
end

class CreditCardNumber < String
  TYPES = {"3[47]\\d{13}"       => "Amex",
           "6011\\d{12}"        => "Discover",
           "5[1-5]\\d{14}"      => "Mastercard",
           "4(\\d{12}|\\d{15})" => "Visa"}

  # Returns the type of the given card, or nil if the card does not match a pattern
  def card_type
    (t = TYPES.detect{|re, t| /^#{re}$/ === self}) && t.last
  end

  # Returns true iff Luhn check passes for this number
  def luhn_valid?
    # a trick: double_and_sum[8] == sum_digits(8*2) == sum_digits(16) == 1 + 6 == 7
    double_and_sum = [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]
    split(//).reverse.mapn{|a,b| a.to_i + double_and_sum[b.to_i]}.sum % 10 == 0
  end

  # Returns true iff card matches a known type and Luhn check passes.
  def valid?
    luhn_valid? && !card_type.nil?
  end
end

if (arg = ARGV.join.gsub(/[^0-9]/, '')) and !arg.empty?
  number = CreditCardNumber.new(arg)

  if number.valid?
    puts "Valid #{number.card_type}"
  else
    puts "Invalid card"
  end
end
