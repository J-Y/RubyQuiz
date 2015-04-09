###########################################
# Ruby quiz #148
# http://www.rubyquiz.com/quiz148.html
# Eric Duminil
# 02/12/2007
#
### It removes unnecesary ().
#
#  ruby postfix_to_infix.rb '56 34 213.7 + * 678 -'
#  56*(34+213.7)-678
#  =13193.2
#
#  ruby postfix_to_infix.rb '1 56 35 + 16 9 - / +'
#  1+(56+35)/(16-9)
#  =14
#
#  ruby postfix_to_infix.rb '1 2+ 4* 5*'
#  (1+2)*4*5
#  =60
#
### You can omit spaces between operands and operators
#
#  ruby postfix_to_infix.rb '1 2+ 4* 5+ 3-'
#  (1+2)*4+5-3
#  =14
#
#  ruby postfix_to_infix.rb '1 2+ 3 4 + +'
#  1+2+3+4
#  =10
#
#  ruby postfix_to_infix.rb '1 2 - 3 4 - -'
#  1-2-(3-4)
#  =0
#
### You can use either ** or ^
### which actually raises troubles while parsing : is "**" == "* *" or "**"=="^"  ?
#
#  ruby postfix_to_infix.rb '2 2 ^ 2 ^'
#  (2^2)^2
#  =16
#
#  ruby postfix_to_infix.rb '2 2 ** 2 **'
#  (2**2)**2
#  =16
#
#  ruby postfix_to_infix.rb '2 3 4 ** **'
#  2**3**4
#  =2417851639229258349412352
#
#  ruby postfix_to_infix.rb '2 3 ** 4 **'
#  (2**3)**4
#  =4096
#
### It raises when something's missing
#
#  ruby postfix_to_infix.rb '1 2+ 4* 5+ 3'
#  postfix_to_infix.rb:94:in `convert_to_infix': ArgumentError
#
#
### No UnaryOperation yet


class Operation
  attr_reader :operator, :operands
  attr_writer :with_parentheses
  def initialize(operator, *operands)
    @operator=operator
    @operands=operands
    @with_parentheses=false
    add_parentheses_to_operands_if_necessary!
  end

  def has_parentheses?
    @with_parentheses
  end
end

class BinaryOperation<Operation
  @@precedence_over={
    '+' =>['',''],
    #no need to put () before -
    '-'  =>['','- +'],
    '*' => ['- +','- +'],
    '/' => ['- +','- + * /'],
    '**'=>['- + * / ^ **','- + * /'],
    '^'=>['- + * / ^ **','- + * /']
  }

  def to_s
    operands.collect{|operand| if operand.is_a?(Operation) && operand.has_parentheses? then
        "(#{operand})"
      else
        operand
      end
    }.join(operator)
  end

  private

  def add_parentheses_to_operands_if_necessary!
    operands.each_with_index{|operand,i|
      operators_with_lower_priority=@@precedence_over[operator][i].split(' ')
      operand.with_parentheses=operators_with_lower_priority.any?{|o| operand.operator == o} if operand.is_a?(BinaryOperation)
    }
  end
end

class Postfix<String
  def split_into_operands_and_operators
    self.scan(/([\w\.]+|\*+|\+|\/|\-|\^)/).flatten
  end

  def to_infix
    @to_infix||=convert_to_infix
  end

  def evaluate
    eval(self.to_infix.gsub(/\^/,'**'))
  end

  private

  def convert_to_infix
    stack=[]
    self.split_into_operands_and_operators.each{|term|
      if term=~/^[\w\.]+$/ then
        stack<<term
      else
        right_operand,left_operand=stack.pop,stack.pop
        stack<<BinaryOperation.new(term,left_operand,right_operand)
      end
    }
    raise ArgumentError unless stack.size==1
    stack.first.to_s
  end
end

p=Postfix.new(ARGV[0])
puts p.to_infix
puts "=#{p.evaluate}"

###########################################
