# Justin Ethier
# December 2007
# Solution to Ruby Quiz 148 - Postfix to Infix
# (http://www.rubyquiz.com/quiz148.html)
#
# Currently only supports operators that are evaluated from left-to-right, however
# it can be extended to support operators other than +, -, * / by adding them to
# the Token class.
#

# This class represents a single token on the infix stack.
# A token may be a single operator / number from the postfix expr,
# or a portion of the infix expr being built.
class Token
  # Accepts a token and optionally the last operator applied
  def initialize(tok, last_op = nil)
    @tok, @last_op = tok, last_op
  end

  # Determines if the current token is an operator
  def is_op?
    case @tok
    when "+", "-", "*", "/"
      return true
    else
      return false
    end    
  end
  
  # Defines the precedence of operators
  def precedence(op)
    case op
    when "*", "/"
      return 5
    when "+", "-"
      return 6
    else
      return nil
    end    
  end
  
  # Returns the token with parentheses added if they are needed for the given op
  def pack(op)
    return "(#{tok})" if last_op != nil and (precedence(op) < precedence(last_op))
    return tok
  end
  
  attr_reader :tok, :last_op
end

# Module of Postfix ==> Infix conversion functions
module PostfixToInfix 
 
  # Main convertion function
  def PostfixToInfix.translate(postfix)
    stack, toks = [], postfix.split(" ").reverse
    
    for tok in toks
      stack << Token.new(tok)
      process_stack(stack)
    end

    process_stack(stack) while stack.size > 1 # Finish stack processing
    stack[0].tok
  end
  
  # Process the current postfix stack, converting to infix if there is enough info
  def PostfixToInfix.process_stack(stack)
    while stack.size > 2 and not stack[-1].is_op? and not stack[-2].is_op? 
      eq = []
      3.times{ eq << stack.pop }
      op = eq[2].tok
      tok = "#{eq[0].pack(op)} #{op} #{eq[1].pack(op)}"
      stack << Token.new(tok, op)
    end    
  end  
end
