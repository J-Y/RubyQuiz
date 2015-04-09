require 'interp'

module Compiler

  # compile expression into bytecode array
  def Compiler.compile(s)
    stack = []
    eval(s.gsub(/(\d+)/, 'Value.new(stack, \1)'))
    stack
  end

  class Value
    attr_reader :value  # constant value or nil for on stack
    ON_STACK = nil

    def initialize(stack, value)
      @stack = stack
      @value = value
    end

    # generate code for each binary operator
    {'+' => Interpreter::Ops::ADD,
     '-' => Interpreter::Ops::SUB,
     '*' => Interpreter::Ops::MUL,
     '**'=> Interpreter::Ops::POW,
     '/' => Interpreter::Ops::DIV,
     '%' => Interpreter::Ops::MOD}.each do |operator, byte_code|
       Value.module_eval <<-OPERATOR_CODE
        def #{operator}(rhs)
          push_if_value(@value)
          push_if_value(rhs.value)
          # swap stack items if necessary
          #{if operator != "+"
              "@stack << Interpreter::Ops::SWAP if rhs.value == nil &&
                                                   @value != nil"
            end}
          @stack << #{byte_code}
          Value.new(@stack, ON_STACK)
        end
       OPERATOR_CODE
    end

    def -@
      if @value != ON_STACK
        push_if_value(-@value)
      else
        push_if_value(0)
        @stack << Interpreter::Ops::SWAP << Interpreter::Ops::SUB
      end
      Value.new(@stack, ON_STACK)
    end

    def +@
      push_if_value(@value)
      Value.new(@stack, ON_STACK)
    end

    def push_if_value(value)
      if value != ON_STACK
        if (-32768..32767).include?(value)
          @stack << Interpreter::Ops::CONST
          @stack.concat([value].pack("n").unpack("C*"))
        else
          @stack << Interpreter::Ops::LCONST
          @stack.concat([value].pack("N").unpack("C*"))
        end
      end
    end

  end
end
