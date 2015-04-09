# -*- ruby -*-
# How to get the ruby program :
#    racc roll.y -o roll.rb
#
# Design :
#   The class Dice correspond to a very general dice. In my programme, "d6" is 
#   dice, but so are "3d6" and "(2d6-3)d(3d4)". A dice simply holds Proc which, 
#   when evaluated, return a random integer corresponding to a (simple or 
#   multiple) dice roll. The dices may be combined using standard arithmetic 
#   operators (+,-,*,/). These operator simply create Proc that roll the two 
#   argument dices. In the design, an integer is considered a d1. However the 
#   Proc for d1 don't use random ... (hopefully ;)
#
#   The tokenize method is pretty simple and the "%" is handled here, replaced 
#   by 100 automatically. Basically, it skips spaces (which flushes the char 
#   buffer however, so that "10 10" is invalid), gather consecutive figures 
#   into numbers and each char is considered an independant token.
#
#   Every grammar aspect is taken care by Racc ...
class DiceParser

  prechigh
    nonassoc UMINUS
    nonassoc SHORTD
    left 'd'
    left '*' '/'
    left '+' '-'
  preclow

rule
  target: exp
        | /* none */ { result = Dice.new 0 }

  exp: exp '+' exp { result += val[2] }
     | exp '-' exp { result -= val[2] }
     | exp '*' exp { result *= val[2] }
     | exp '/' exp { result /= val[2] }
     | '(' exp ')' { result = val[1] }
     | '-' NUMBER  = UMINUS { result = Dice.new(-val[1]) }
     | NUMBER      { result = Dice.new val[0] }
     | exp 'd' exp { result = Dice.new val[0], val[2] }
     | 'd' exp = SHORTD { result = Dice.new 1, val[1] }

---- header

$debug_dice = false
$debug_token = false

class Dice

  attr_reader :size, :act

  def initialize(number, size = 1)
    @size = size
    if number.respond_to? :to_proc
      puts "Initialize with proc" if $debug_dice
      @act = number.to_proc
      @size = 0
    elsif size == 1 then
      puts "Initialize with 1-sided dice(s)" if $debug_dice
      @act = lambda { number }
    else
      puts "Initialize with full dice(s)" if $debug_dice
      number = Dice.new number unless number.respond_to? :roll # at that point, number must be a Dice
      @act = lambda do
        result = 0
        s = size.roll
        n = number.roll
        result = (1..n.to_i).inject(0) { |sum,ii| sum + random(s) }
        puts "Rolling #{n}d#{s} = #{result}" if $debug_dice
        result
      end
    end
  end

  def random(sides)
    rand(sides)+1
  end

  def roll
    act[]
  end

  def self.define_op(op)
    module_eval <<-EOF
    def #{op}(other)
      if (size == 1) && (other.size == 1) then
        Dice.new(self.roll #{op} other.roll)
      else
        Dice.new(lambda { self.roll #{op} other.roll })
      end
    end
    EOF
  end

  define_op :+
  define_op :*
  define_op :-
  define_op :/

end

---- inner

  attr_accessor :string, :result

  def parse( str )
    @result = []
    #@yydebug = true
    @string = str
    yyparse( self, :tokens )
  end

  def tokens
    buffer = ""
    string.each_byte do |b|
      print "b=#{b}/#{b.chr}, buffer = '#{buffer}'\n" if $debug_token
      case b
      when ?0..?9
        buffer << b.chr
        print "Added #{b.chr} to buffer => #{buffer}\n" if $debug_token
      when [?\ ,?\t,?\n]
        yield :NUMBER, buffer.to_i unless buffer.empty?
        print "Pushing : #{buffer}\n" unless buffer.empty? if $debug_token
        buffer = ""
      when ?%
        yield :NUMBER, buffer.to_i unless buffer.empty?
        print "Pushing : #{buffer}\n" unless buffer.empty? if $debug_token
        yield :NUMBER, 100
      else
        yield :NUMBER, buffer.to_i unless buffer.empty?
        print "Pushing : #{buffer}\n" unless buffer.empty? if $debug_token
        buffer = ""
        yield b.chr, b.chr
        print "Pushing : #{b.chr}\n" if $debug_token
      end
    end
    yield :NUMBER, buffer.to_i unless buffer.empty?
    print "Pushing : #{buffer}\n" unless buffer.empty? if $debug_token
    yield false, '$end'
  end

---- footer

string = ARGV[0]

# puts "Parsing : '#{string}'"
value = DiceParser.new.parse( string )

num = ARGV[1] || 1

num.to_i.times do
  print "#{value.roll} "
end
print "\n"
