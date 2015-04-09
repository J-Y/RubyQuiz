#!/usr/bin/env ruby

class Fixnum
  def d other
    # Raise an error if we have an invalid combination
    raise "Invalid dice" if self < 1 || other < 1
    # Roll the "other"-sided dice "self"-times
    Array.new(self) { rand(other)+1 } .inject { |x,sum| sum += x }
  end
end

class Dice
  def initialize(str)
    # Global substition of
    # <operator>d to <operator>1d  <operator> = /*+-
    # d% to d100
    # dx to d(x)  x = integer
    # d to .d
    @str = str.gsub(/[\/\+\-\*]d/) { |match| match[0..0] + "1d" }
.gsub(/d%/,"d100") .gsub(/(d\s*\d+)/) { |match| "d(" +
match.delete('d') + ")" } .gsub(/d/,".d")
    #@str should now hold valid ruby code to roll the dice
  end
  def roll
    #just evaluate @str
    eval @str
  end
end

# Take the arguments, create a new dice and roll it
d = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times { print "#{d.roll} " }
