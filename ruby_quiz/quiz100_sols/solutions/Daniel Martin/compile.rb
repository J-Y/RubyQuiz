# This is a solution to Ruby Quiz #100
#
# It's basically just a shunting algorithm, but with a twist
# since it needs to distinguish between a "-" that's part of
# a number and a "-" that's an operator.  To do that, I use
# a state machine while parsing to remember if I need next
# an operator or an integer.

require 'strscan'
class Compiler
  # A small class made so that I can use case ... when
  # with a StringScanner
  class Token < Regexp
    def initialize(re)
      super(re)
    end
    # Using is_a? instead of respond_to? isn't very duck-typey,
    # but unfortunately String#scan and StringScanner#scan mean
    # completely different things.
    def ===(s)
      if (s.is_a?(StringScanner))
        s.scan(self)
      else
        super(s)
      end
    end
  end

  # The tokens I need
  WSPACE = Token.new(/\s+/)
  LPAREN = Token.new(/\(/)
  RPAREN = Token.new(/\)/)
  OP  = Token.new(/\*\*|[+*%\/-]/)
  NEG = Token.new(/-/)
  INT = Token.new(/\d+/)

  OpValMap = {'+' => 0x0a, '-' => 0x0b, '*' => 0x0c,
              '**' => 0x0d, '/' => 0x0e, '%' => 0x0f}

  def initialize(instring)
    @scanner = StringScanner.new(instring)
    @opstack = Array.new
    @outarr = Array.new
  end

  def compile()
    state = :state_int
    while state != :state_end
      case @scanner
      when WSPACE
        next
      else 
        state = send(state)
        raise "Syntax error at index #{@scanner.pos}" if ! state
      end
    end
    while ! @opstack.empty?
      op = @opstack.pop
      raise "Mismatched parens" if LPAREN === op
      @outarr << OpValMap[op]
    end
    @outarr
  end

  # Class method as required by the test harness
  def self.compile(instring)
    new(instring).compile
  end

  private
  # Expecting an operator or right paren
  def state_op
    case @scanner
    when RPAREN
      while not LPAREN === @opstack[-1]
        raise "Mismatched parens" if @opstack.empty?
        @outarr << OpValMap[@opstack.pop]
      end
      @opstack.pop
      :state_op
    when OP
      op = @scanner.matched
      while is_lower(@opstack[-1], op)
        @outarr << OpValMap[@opstack.pop]
      end
      @opstack << op
      :state_int
    else
      # I would handle this with an EOS token, but unfortunately
      # StringScanner is broken w.r.t. @scanner.scan(/$/)
      :state_end if @scanner.eos?
    end
  end

  # state where we're expecting an integer or left paren
  def state_int
    case @scanner
    when LPAREN
      @opstack << @scanner.matched
      :state_int
    when INT
      integer(@scanner.matched.to_i)
      :state_op
    when NEG
      :state_neg
    end
  end

  # The state where we've seen a minus and are expecting
  # the rest of the integer
  def state_neg
    case @scanner
    when INT
      integer(-(@scanner.matched.to_i))
      :state_op
    end
  end

  # Handle an integer
  def integer(i)
    if (i <= 32767 and i >= -32768)
      @outarr << 0x01
      @outarr.push(*([i].pack("n").unpack("C*")))
    else
      @outarr << 0x02
      @outarr.push(*([i].pack("N").unpack("C*")))
    end
  end

  # Define the precedence order
  # One thing to note is that for an operator a,
  # is_lower(a,a) being true will make that operator
  # left-associative, while is_lower(a,a) being false
  # makes that operator right-associative.  Note that
  # we want ** to be right associative, but all other
  # operators to be left associative.
  def is_lower(op_on_stack, op_in_hand)
    case op_on_stack
      when nil, LPAREN; false
      when /\*\*|[*\/%]/; op_in_hand =~ /^.$/
      when /[+-]/;        op_in_hand =~ /[+-]/
    end
  end
end
