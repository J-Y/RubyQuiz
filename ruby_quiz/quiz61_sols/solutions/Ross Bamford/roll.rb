#!/usr/local/bin/ruby
#
# Ruby Quiz 61, the quick way
# by Ross Bamford

# Just a debugging helper
module Kernel
  def dbg(*s)
    puts(*s) if $VERBOSE|| @dice_debug
  end
  attr_writer :dice_debug
  def dice_debug?; @dice_debug; end
end

# Need to implement the 'rolls' method. Wish it didn't have to
# be on Fixnum but for this it makes the parsing *lots* easier.
class Fixnum
  def self.roll_proc=(blk)
    @roll_proc = blk
  end

 def self.roll_proc
    @roll_proc ||= method(:rand).to_proc
  end

  def rolls(sides)
    (1..self).inject(0) { |s,v| s + Fixnum.roll_proc[sides] }
  end
end

# Here's the roller.
class DiceRoller 
  class << self
    # Completely wrap up a roll
    def roll(expr, count = 1, debug = false)
      new(expr,debug).roll(count)
    end

    # The main 'parse' method. Just really coerces the code to Ruby
    # and then compiles to a block that returns the result.
    def parse(expr)
      # very general check here. Will pass lots of invalid syntax,
      # but hopefully that won't compile later. This removes the
      # possibility of using variables and the like, but that wasn't
      # required anyway. The regexps would be a bit more difficult
      # if we wanted to do that.
      raise SyntaxError, "'#{expr}' is not a valid dice expression", [] if expr =~ /[^d\d\(\)\+\-\*\/\%]|[^d]%|d-|\*\*/

      # Rubify!
      s = expr.gsub( /([^\d\)])d|^d/,   '\11d')          # fix e.g. 'd5' and '33+d3' to '1.d5' and '33+1d3'
      s.gsub!(       /d%/,              'd(100)'  )      # fix e.g. 'd%' to 'd(100)'
      s.gsub!(       /d([\+\-]?\d+)/,   '.rolls(\1)')    # fix e.g. '3d8' to '3.rolls(8)
      s.gsub!(       /d\(/,             '.rolls(')       # fix e.g. '2d(5+5)' to '2.rolls(5+5)' 

      # Make a block. Doing it this way gets Ruby to compile it now 
      # so we'll reliably get fail fast on bad syntax.
      dbg "PARS: #{expr} => #{s}"
      begin
        eval("lambda { #{s} }")
      rescue Exception => ex
        raise SyntaxError, "#{expr} is not a valid dice expression", []
      end
    end
  end
  
  # Create a new roller that rolls the specified dice expression
  def initialize(expr, debug = false)
    dbg "NEW : #{to_s}: #{expr} => #{expr_code}" 
    @expr_code, @expr, @debug = expr, DiceRoller.parse(expr), debug
  end

  # Get hold of the original expression and compiled block, respectively
  attr_reader :expr_code, :expr

  # Roll this roller count times
  def roll(count = 1)
    dbg "  ROLL: #{to_s}: #{count} times"
    r = (1..count).inject([]) do |totals,v|      
      this_r = begin
        expr.call
      rescue Exception => ex
        raise RuntimeError, "'#{expr_code}' raised: #{ex}", []
      end
      
      dbg "    r#{v}: rolled #{this_r}"
      totals << this_r
    end

    r.length < 2 ? r[0] : r
  end
end

# Library usage:
#
#   require 'roll'
#   
#   # is the default:
#   # Fixnum.roll_proc = lambda { |sides| rand(sides) + 1 }
#   
#   DiceRoller.roll('1+2*d6')
#   
#   d = DiceRoller.new('((3d%)+8*(d(5*5)))')
#   d.roll(5)
#
#   d = DiceRoller.new('45*10d3')   # debug
#
#   # ... or
#   one_roll = d.expr.call
#

# command-line usage
if $0 == __FILE__
  unless expr = ARGV[0]
    puts "Usage: ruby [--verbose] roll.rb expr [count]"
  else
    (ARGV[1] || 1).to_i.times { print "#{DiceRoller.roll(expr)}  " }
    print "\n"
  end
end


