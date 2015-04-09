require "Interpreter.rb"

class Compiler

  @PRECEDENCE = {
    '(' => -1,
    ')' => -1,
    '+' => 0,
    '-' => 0,
    '*' => 1,
    '/' => 1,
    '**' => 3,
    '%' => 3
  }

  @BYTECODE = {
    'CONST' => 0x01,
    'LCONST' => 0x02,
    '+' => 0x0a,
    '-' => 0x0b,
    '*' => 0x0c,
    '**' => 0x0d,
    '/' => 0x0e,
    '%' => 0x0f,
    'SWAP' => 0xa0
  }

  def Compiler.compile(expression)
    te = self.tokenize(expression)
    be = self.parse(te)
    self.to_bytecode(be)
  end

  def Compiler.tokenize(expression)
    tokenized_expression = []

    expression.gsub!(/\s+/, "")
    expression.scan(/(\d+|\(|\)|\+|-|\*\*|\*|\/|\%)/) { |e| tokenized_expression.push(e) }
    tokenized_expression
  end

  def Compiler.parse(tokenized_expression)
    output_queue, operator_stack = [], []
    operator = nil

    tokenized_expression.each { |token|

      # If token is a number, place on output queue
      if (token[0] =~ /^\d+$/)
        output_queue.push(token[0].to_i)
      elsif (token[0] == '(')
        operator_stack.push(token[0])
      elsif (token[0] == ')')
        # Pop operators off stack and onto output queue until left
        # bracket encountered
        while (operator != '(')
          if ((operator = operator_stack.pop) != '(')
              output_queue.push(operator)
          end
        end
      else
        # If there are any operators, check precedence of current token
        # against last operator on queue.  If the operator on queue is
        # more important, add it to the output before pushing the current
        # operator on
        if (operator_stack.any? && (@PRECEDENCE[token[0]] <= @PRECEDENCE[operator_stack.last]))
          output_queue.push(operator_stack.pop)
        end
        operator_stack.push(token[0])
      end
    }

    # Add the remaining operators to end of the output queue
    operator_stack.reverse_each { |operator|
      output_queue.push(operator)
    }

    output_queue
  end

  def Compiler.to_bytecode(bnf_expression)
    stack = []

    bnf_expression.delete("(")
    bnf_expression.each { |token|
      case token
        when Integer
           # If number is small enough, use smaller 2 byte storage

          if ((token >= -32768) && (token <= 32767))
            stack.push(@BYTECODE['CONST'])
            stack.push(token >> 8, token)
          else
            stack.push(@BYTECODE['LCONST'])
            stack.push(token >> 24, token >> 16, token >> 8, token)
          end
        else
          stack.push(@BYTECODE[token])
      end
    }
    stack
  end

end

require "TestByteCode.rb"
