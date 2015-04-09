# Author: J. Eric Ivancich
# Date: 2006-11-04
#
# Contains a solution to Ruby Quiz #100 as described at:
#   http://www.rubyquiz.com/quiz100.html .
#
# To invoke, call Compiler.compile passing a String containing a Ruby
# mathematical expression as a parameter.  It returns an array of
# numbers representing the sequence of bytecodes used to implement
# the expression on the virtual machine described in the quiz.

module Compiler
  protected 

  Debug = false   # :nodoc: set to true for extra output

  # the op codes
  OpCodes = {
    :const => 0x01, :lconst => 0x02, :add => 0x0a, :sub => 0x0b,
    :mul => 0x0c, :pow => 0x0d, :div => 0x0e, :mod => 0x0f,
    :swap => 0xa0 } # :nodoc:


  # An instance of class Operator stores information about an operator
  # (e.g., symbol, bytecode instruction, precedence level, and left/right
  # associativity) to aid in parsing an expression.
  class Operator # :nodoc:
    attr_reader :symbol, :instruction, :precedence, :associativity

    def initialize(symbol, instruction, precedence, associativity = :left)
      @symbol, @instruction, @precedence, @associativity =
        symbol, instruction, precedence, associativity
    end
  end

  # Operators contains a hash of all operators keyed by the source code
  # symbol.  The left paren is not really an operator, but the shunting
  # yard algorithm treats it as such for the purpose of matching a close
  # parentheses.
  Operators = Hash.new  # :nodoc:
  [Operator.new("+", :add, 1),
    Operator.new("-", :sub, 1),
    Operator.new("*", :mul, 2),
    Operator.new("/", :div, 2),
    Operator.new("%", :mod, 2),
    Operator.new("**", :pow, 3, :right),
    Operator.new("(", nil, 0)].each { |op| Operators[op.symbol] = op }


  # An instance of class Code stores a sequence of bytecodes.  The logic
  # of converting operators and numbers to bytecodes is embedded in the
  # add method.
  class Code  # :nodoc:
    attr_reader :bytes

    def initialize()
      @bytes = Array.new
    end

    # Adds either an integer constant or an operator to the byte sequence.
    def add(item)
      if item.kind_of?(Operator)                 # add an operator
        @bytes << OpCodes[item.instruction]
      elsif item.kind_of?(Integer)               # add a constant
        if item >= -(2**15) && item < 2**15      # add a short constant
          @bytes << OpCodes[:const]
          8.step(0, -8) { |shift| @bytes << ((item >> shift) & 0xff) }
        elsif item >= -(2**31) && item < 2**31   # add a long constant
          @bytes << OpCodes[:lconst]
          24.step(0, -8) { |shift| @bytes << ((item >> shift) & 0xff) }
        else                             # error: constant too big
          raise("Error: number requires too many bits -- \"#{item}\"")
        end
      else                               # error: neither operator nor constant
        raise("Bug: could not encode \"#{item}\"")
      end
    end
  end

  #--
  # The following three methods implement Edsger Dijkstra's "shunting
  # yard algorithm" as documented at:
  #
  #   Shunting yard algorithm. (2006, September 21). In Wikipedia,
  #     The Free Encyclopedia. Retrieved 01:07, November 5, 2006, from
  #     http://en.wikipedia.org/w/index.php?title=Shunting_yard_algorithm&oldid=76960745
  #
  # The first two methods help the third, which is the interface to the
  # entire module.
  #++


  # Parses either a number or an open parentheses, modifying source,
  # bytecode, and stack according to the shunting yard algorithm.  Returns
  # what the parser expect to find next.
  def Compiler.parse_num_or_open_paren(source, bytecode, stack)
    if source =~ /^(\+|-)?\d+/                        # handle number
      puts "parsed num \"#{$~[0]}\"" if Debug
      bytecode.add($~[0].to_i)
      source.replace($~.post_match)
      return :op_or_close_paren
    elsif source =~ /^\(/                             # handle open paren
      puts "parsed lparen \"#{$~[0]}\"" if Debug
      stack.push(Operators["("])
      source.replace($~.post_match)
      return :num_or_open_paren
    else
      raise("Error: could not parse \"#{source}\"")
    end
  end

  # Parses either an operator or a close parentheses, modifying source,
  # bytecode, and stack according to the shunting yard algorithm.  Returns
  # what the parser expect to find next.
  def Compiler.parse_op_or_close_paren(source, bytecode, stack)
    if source =~ /^(\+|-|\*{1,2}|\/|%)/                # handle operator
      puts "parsed op \"#{$~[0]}\"" if Debug
      op = Operators[$~[0]]

      # deal with operators of higher and/or equal precedence (depending
      # on associativity)
      while stack.length > 0 &&
            ((op.associativity == :left &&
              op.precedence <= stack[-1].precedence) ||
             (op.associativity == :right &&
              op.precedence < stack[-1].precedence))
        bytecode.add(stack.pop)
      end

      stack.push(op)
      source.replace($~.post_match)
      return :num_or_open_paren
    elsif source =~ /^\)/                              # handle close paren
      puts "parsed rparen \"#{$~[0]}\"" if Debug
      open_paren = Operators["("]

      # transfer all operators within parentheses to bytecode
      while stack.length > 0 &&
            stack[-1].precedence > open_paren.precedence
        bytecode.add(stack.pop)
      end

      # now expect to find matching open parentheses
      raise("Error: parentheses problem") if stack.pop != Operators["("]

      source.replace($~.post_match)
      return :op_or_close_paren
    else
      raise("Error: could not parse \"#{source}\"")
    end
  end

  public

  # Interface to the module.  Takes a Ruby mathematical expression as a
  # String and returns an array of byte codes as defined in
  # {Ruby Quiz #100}[http://www.rubyquiz.com/quiz100.html].
  #--
  # Converting from an infix expression to what is essentially a postfix
  # notation is done using the shunting yard algorithm.  The code as it
  # is generated is added to variable bytecode.  Operators being held during
  # the look-ahead process are stored on the variable stack.
  #
  # There's also a simple two-state state machine, the state designating
  # what is next expected in the source, which can be either:
  #   1) a number or an open parentheses
  #   2) an operator or a close parentheses
  #
  # A separate method handles each of the two states.
  def Compiler.compile(source)
    bytecode = Code.new
    stack = Array.new
    source = source.gsub(/\s/, "")   # use copy w/ all whitespace removed

    # work way through source code using a simple two-state state
    # machine; either expecting a number or open parentheses or
    # expecting an operator or close parentheses
    expect = :num_or_open_paren
    while source.length > 0
      puts "working on \"#{source}\"" if Debug
      case expect
      when :num_or_open_paren
        expect = parse_num_or_open_paren(source, bytecode, stack)
      when :op_or_close_paren
        expect = parse_op_or_close_paren(source, bytecode, stack)
      else
        raise("Bug: illegal state -- #{expect}")
      end
    end

    # pop any remaining operators on stack
    until stack.empty?
      op = stack.pop

      # check for any left over parentheses (i.e., op.instruction will be nil)
      raise ("Error: parentheses problem") unless op.instruction

      bytecode.add(op)
    end

    bytecode.bytes  # return the array of bytecodes
  end
end
