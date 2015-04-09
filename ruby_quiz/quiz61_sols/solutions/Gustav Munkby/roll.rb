#!/usr/bin/env ruby
#
# Ruby Quiz #61, Dice Roller
# http://www.rubyquiz.com/quiz61.html
#
# You should write a program that takes two arguments:
#  * a dice expression
#  * the number of times to roll it (default = 1)
#
# A dice expression looks somthing like this, plus
# a couple of rules which defines precedence and
# whatnot.
#
#   <expr> := <expr> + <expr>
#           | <expr> - <expr>
#           | <expr> * <expr>
#           | <expr> / <expr>
#           | [<expr>] d <expr>
#           | ( <expr> )
#           | integer
#
# I solved this by delegating the task to Ruby. Since
# Ruby has built-in support for all these operations
# except the "d"-operation, that was the only thing
# which needed implementation.
#
# The quest for something with similar precedance which
# would work with minimal modification to the input
# yielded the following solution which replaces the
# "d"-operation with a method call on the integer object.
#
# Then all that has to be taken care of is to add
# paranthesis to the rhs, if neccessary, and to add a
# dot (.) in front of the d:s.
#
# If we would just do this, and then eval, the user
# could spawn much more complicated behaviour than what
# was intended, so therefore validation of the input
# string is added to ensure that the program works
# according to the specification
#

class Integer
  # The dice-roll operation, Roll a dice of the specified
  # size, as many times as this number represents
  def dice(size)
    self + (1..self).inject(0) do |sum, i|
      sum + rand(size)
    end
  end
end

class Dice
  Expression = /[1-9]\d*(?:[+-\/*d][1-9]\d*)*/

  def initialize(str)
    str = str.gsub(/(^|[\(+-\/*])d/, '\11d') # Implicit 1 before d
    raise Exception.new("Illegal pattern") unless valid?(str.dup)
    str.gsub!(/d(\d+)/, 'd(\1)')             # Paranthesis if we must
    str.gsub!(/d/, '.dice')                  # Method call requires .
    instance_eval "def roll; #{str}; end"
  end

  private
  # Validation method, this will destroy the input string
  def valid?(str)
    nil while str.gsub!(/\(#{Expression}\)/,'1') unless str=~/\)\(/
    str =~ /^#{Expression}$/
  end
end

d = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times { print "#{d.roll}  " }
puts
