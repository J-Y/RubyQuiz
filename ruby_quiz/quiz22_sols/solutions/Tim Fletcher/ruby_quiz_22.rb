#!/usr/bin/env ruby

module RomanNumerals
  BASICS = { 'I'=>1, 'V'=>5, 'X'=>10, 'L'=>50, 'C'=>100, 'D'=>500, 'M'=>1000 }
  def self.convert( n )
    (48..57) === n[0] ? arabic_to_roman( n ) : roman_to_arabic( n )
  end
  def self.roman_to_arabic( n )
    total, previous = 0, 0  
    n.to_s.split(//).reverse.each do |numeral|
      current = BASICS[ numeral.upcase ]
      total += previous
      total -= 2 * current if current < previous
      previous = current
    end
    total += previous
    return total
  end
  def self.arabic_to_roman( n )
    numerals, tens, basic = [], 1, BASICS.invert  
    n.to_s.split(//).collect { |i| i.to_i }.reverse.each do |digit|
      numerals.unshift case digit
        when 2, 3     then basic[ tens ] * digit
        when 4        then basic[ tens ] + basic[ tens * 5 ]
        when 9        then basic[ tens ] + basic[ tens * 10 ]
        when 6, 7, 8  then basic[ tens * 5 ] + basic[ tens ] * ( digit - 5 )
        when 1, 5     then basic[ tens * digit ]
      end
      tens = tens * 10
    end
    return numerals.to_s
  end
end

if ARGV.empty?
  ARGV.push( $stdin.read.chomp )
else
  ARGV.collect! { |file| IO.read( file ) }
end

ARGV.collect! do |input|
  input.split("\n").collect { |line| RomanNumerals.convert( line ) }.join("\n")
end

$stdout.write ARGV.join("\n")+"\n"


