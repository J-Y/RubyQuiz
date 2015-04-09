#!/usr/local/bin/ruby

require 'roll'

LOW_DICE  = lambda { |sides| 1 }
HIGH_DICE = lambda { |sides| sides }

# Adds a 'minmax' method that uses loaded dice to find
# min/max achievable for a given expression.
# 
# Obviously not thread safe, but then neither is the
# whole thing ;D
class DiceRoller  
  def self.minmax(expr)
    old_proc = Fixnum.roll_proc
    Fixnum.roll_proc = LOW_DICE
    low = DiceRoller.roll(expr)

    Fixnum.roll_proc = HIGH_DICE
    high = DiceRoller.roll(expr)
    Fixnum.roll_proc = old_proc
    
    [low,high]
  end
end

if $0 == __FILE__
  if expr = ARGV[0]
    min, max = DiceRoller.minmax(expr)
    puts "Expression: #{expr} ; min / max = #{min} / #{max}"
  else
    puts "Usage: minmax.rb <expr>"
  end
end
