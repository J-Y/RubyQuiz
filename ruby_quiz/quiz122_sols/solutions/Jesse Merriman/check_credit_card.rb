#!/usr/bin/env ruby
# check_credit_card.rb
# Ruby Quiz 122: Checking Credit Cards

require 'set'

class Integer
  # Determine if this number is a prefix of the given string for the given base.
  def prefix_of? str, base = 10
    not /^#{to_s(base)}/.match(str).nil?
  end
end

class Range
  # Determine if any numbers within this range is a prefix of the given string
  # for the given base.
  def prefix_of? str, base = 10
    # We could use the first case every time, but the second is much quicker
    # for large ranges.
    if str[0].chr == '0'
      any? { |num| num.prefix_of? str, base }
    else
      num = str.slice(0..(max.to_s(base).length-1)).to_i
      num >= min and num <= max
    end
  end
end

class Card
  attr_accessor :name

  # Turn arg into a Set instance variable based on its class.
  # This is so initialize can easily accept a few different argument types.
  def add_set_ivar ivar, arg
    case arg
      when Set;   instance_variable_set ivar, arg
      when Array; instance_variable_set ivar, Set.new(arg)
      else;       instance_variable_set ivar, Set[arg]
    end
  end

  # prefixes can be:
  #   - a single number
  #   - an Array of numbers
  #   - a Range of numbers
  #   - an Array of numbers and Ranges
  #   - a Set of numbers
  #   - a Set of numbers and Ranges
  #
  # lengths can be:
  #   - a single number
  #   - an Array of numbers
  #   - a Set of numbers
  def initialize name, prefixes, lengths
    @name = name
    add_set_ivar :@prefixes, prefixes
    add_set_ivar :@lengths,  lengths
  end

  # Determine if a number is valid for this card.
  def valid? num
    num = num.to_s
    @prefixes.any? { |pre| pre.prefix_of? num } and
     @lengths.any? { |len| len == num.length  }
  end

  # Determine if the given number passes the Luhn algorithm.
  # This is pretty damn dense.. perhaps I should spread it out more..
  def Card.luhn_valid? num
    digits = num.to_s.split(//).map! { |d| d.to_i }    # separate digits
    (digits.size-2).step(0,-2) { |i| digits[i] *= 2 }  # double every other
    digits.map! { |d| d < 10 ? d : [1,d-10] }.flatten! # split up those > 10
    (digits.inject { |sum, d| sum + d } % 10).zero?    # sum divisible by 10?
  end
end

if $0 == __FILE__
  CardPool = Set[
    Card.new('AMEX',       [34,37],      15),
    Card.new('Discover',   6011,         16),
    Card.new('MasterCard', (51..55),     16),
    Card.new('Visa',       4,            [13,16]),
    Card.new('JCB',        (3528..3589), 16),
    Card.new('Diners',     [(3000..3029),(3040..3059),36,(3815..3889),389], 14)
  ]

  card_num = $stdin.gets.chomp.gsub! /\s/, ''
  cards = CardPool.select { |c| c.valid? card_num }

  if cards.size.zero?
    puts "Unknown card."
  else
    puts "Number matched #{cards.size} cards:"
    cards.each { |c| puts "  #{c.name}" }
  end

  if Card.luhn_valid?(card_num); puts 'Passed Luhn algorithm'
  else;                          puts 'Failed Luhn algorithm'; end
end
