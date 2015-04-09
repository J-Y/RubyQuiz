#postfix to infix
# ruby quix #148
# Adam Shelly
# v2
#  Converts postfix to infix notation
#  uses ruby's operators & precedence rules

$Operators = {
 '&&'=>'0 ', '||'=>'0 ',
 '=='=>'1 ', '==='=>'1 ', '<=>'=>'1 ',
 '<='=>'2 ', '>='=>'2 ',   '<' =>'2 ', '>'=>'2 ',
 '^' =>'3 ',  '|' =>'3 ',
 '&' =>'4 ',
 '<<'=>'5L', '>>'=>'5L',
 '+' =>'6 ',  '-' =>'6L',
 '*' =>'7 ',  '/' =>'7L', '%'=> '7L',
 '**'=>'8R',
 :term=>'10 '
 }

class Term
 attr_reader :precedence, :dir
 def initialize str, groupPrec=nil
  @s = str
  @precedence = $Operators[str]||groupPrec||$Operators[:term]
  @dir = @precedence[-1].chr
  @precedence = @precedence.to_i
  end
 def isOp
  @precedence != $Operators[:term].to_i
 end
 def parenthesize
  @s="(#{@s})"
 end
 def to_s
  @s
 end
end

class Infix
 def initialize rpn
  stack=[]
  rpn.split.each do |t|
    term = Term.new(t)
    if term.isOp
      rval = stack.pop
      lval = stack.pop
      raise "Empty Stack" unless lval && rval
      lval.parenthesize if lval.precedence < term.precedence or
        term.dir=='R'&& lval.precedence == term.precedence
      rval.parenthesize if rval.precedence < term.precedence or
        term.dir=='L'&& rval.precedence == term.precedence
      phrase = "#{lval} #{term} #{rval}"
      term = Term.new(phrase,term.precedence)
      #p term
    end
    stack.push term
  end
  @expr = stack.pop
   raise "Extra terms" unless stack.size==0
 end
 def to_s
  @expr.to_s
 end
end

def test
  puts Infix.new('2 3 +').to_s                 == '2 + 3'
  puts Infix.new('56 34 213.7 + * 678 -').to_s == '56 * (34 + 213.7) - 678'
  puts Infix.new('1 56 35 + 16 9 - / +').to_s  == '1 + (56 + 35) / (16 - 9)'
  puts Infix.new('1 2 + 3 4 + +').to_s         == '1 + 2 + 3 + 4'
  puts Infix.new('1 2 - 3 4 - -') .to_s        == '1 - 2 - (3 - 4)'
  puts Infix.new('2 2 ** 2 **').to_s           == '(2 ** 2) ** 2'
  puts Infix.new('2 2 2 ** **').to_s           == '2 ** 2 ** 2'
  puts Infix.new('1 2 3 4 5 + + + +').to_s     ==  '1 + 2 + 3 + 4 + 5'
  puts Infix.new('1 2 3 4 5 / / - -').to_s     ==  '1 - (2 - 3 / (4 / 5))'
  puts Infix.new('3 5 * 5 8 * /').to_s         ==  '3 * 5 / (5 * 8)'
  puts Infix.new('3 5 + 5 8 + -').to_s         ==  '3 + 5 - (5 + 8)'
  puts Infix.new('a b == c 1 + 2 < &&').to_s   == 'a == b && c + 1 < 2'
  puts Infix.new('1 2 << 4 <<').to_s           == '1 << 2 << 4'
  puts Infix.new('1 2 4 << <<').to_s           == '1 << (2 << 4)'
end

if __FILE__ == $0
  if ARGV.empty?
     test
   else
    puts Infix.new(ARGV.join(' ')).to_s
  end
end
