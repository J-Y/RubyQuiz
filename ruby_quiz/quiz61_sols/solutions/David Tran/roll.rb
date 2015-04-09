# Ideally it is better generate an "simplified" AST tree"
# for example expression "3d6+(1+2*5)" will have "3d6+11" AST Tree,
# and each roll operation will just do the tree walking to calculate the value.
#
# Unfortunately, with ANTLR 3ea7, the syntax change from version 2.7.6
# and I am not able to create an AST Tree for Ruby language.
#
# This forces me to reparse for each roll operation. Really bad :(.

require 'DiceCalculator'
require 'DiceCalculatorLexer'

class Dice
 def initialize(input)
   @sstream = StringStream.new(input)
 end

 def roll
   lexer = DiceCalculatorLexer.new(ANTLR::CharStream.new(@sstream.rewind))
   parser = DiceCalculator.new(ANTLR::TokenStream.new(lexer))
   parser.parse
   parser.result
 end

 # help class, treat String as IO
 class StringStream
   def initialize(str)
     @str = str
     @pos = 0
   end

   def read(n)
     return nil if @pos >= @str.size
     s = @str[@pos, n]
     @pos += n
     s
   end

   def rewind
     @pos = 0
     self
   end
 end
end

if $0 == __FILE__
 abort("Usage: #$0 expression [count]") if ARGV.size <= 0
 d = Dice.new(ARGV[0])
 (ARGV[1] || 1).to_i.times { print "#{d.roll} " }
end
