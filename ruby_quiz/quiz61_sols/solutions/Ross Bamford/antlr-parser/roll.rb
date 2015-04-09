#!/usr/local/bin/ruby
#
# Ruby Quiz, number 61 - Dice roller
# This entry by Ross Bamford (rosco<at>roscopeco.co.uk)
#
# Based on Antlr v3 Ruby back-end. Tested *only* with 3.0-ea7
#
# I've gone for simplicity here, so I've stayed out of the
# math you RPG guys seem to love, and gone for simplicity over
# efficiency or performance.

require 'Dice'
require 'DiceLexer'
require 'stringio'

# redefine error reporting
class Dice
  def report_error(ex)
    begin
      token = @input.look_ahead(1)
    rescue
      token = Token::INVALID
    end
    
    raise SyntaxError.exception, "Couldn't parse #{token_names[token.token_type]}", [@ruleStack.join(', ')]
  end
end

class DiceRoller
  class << self
    def roll(expr, &blk)
      lexer = DiceLexer.new(ANTLR::CharStream.new(StringIO.new(expr)))
      parser = Dice.new(ANTLR::TokenStream.new(lexer))

      parser.roll_proc = blk if blk

      parser.parse
      parser.result
    end  
  end
end

if $0 == __FILE__
  unless expr = ARGV[0]
    puts "Usage: ruby [--verbose] roll.rb expr [count]"
  else
    (ARGV[1] || 1).to_i.times { print "#{DiceRoller.roll(expr)}  " }
    print "\n"
  end
end

