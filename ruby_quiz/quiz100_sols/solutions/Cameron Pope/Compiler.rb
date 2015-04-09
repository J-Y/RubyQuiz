# Operator overrides to create an expression tree. Mixed into
# Const and Expr so:
#   Const <op> Const => Expr
#   Const <op> Expr => Expr
#   Expr <op> Const => Expr
module CreateExpressions
  def +(other) Expr.new(:add, self, other) end
  def -(other) Expr.new(:sub, self, other) end
  def *(other) Expr.new(:mul, self, other) end
  def /(other) Expr.new(:div, self, other) end
  def %(other) Expr.new(:mod, self, other) end
  def **(other) Expr.new(:pow, self, other) end
end

# Add a method to fixnum to create a const from an integer
class Fixnum
  def to_const
    Const.new(self)
  end
end

# An integer value
class Const
  include CreateExpressions
  # Opcodes to push shorts or longs respectively onto the stack
  OPCODES = {2 => 0x01, 4 => 0x02}

  def initialize(i)
    @value = i
  end

  def to_s
    @value
  end

  # Emits the bytecodes to push a constant on the stack
  def emit
    # Get the bytes in network byte order
    case @value
      when (-32768..32767): bytes = [@value].pack("n").unpack("C*")
      else bytes = [@value].pack("N").unpack("C*")
    end
    bytes.insert 0, OPCODES[bytes.size]
  end
end

# A binary expression
class Expr
  include CreateExpressions
  OPCODES = {:add => 0x0a, :sub => 0x0b, :mul => 0x0c, :pow => 0x0d,
    :div => 0x0e, :mod => 0x0f}

  def initialize(op, a, b)
    @op = op
    @first = a
    @second = b
  end

  # Emits a human-readable s-expression for testing
  # (preorder traversal of parse tree)
  def to_s
    "(#{@op.to_s} #{@first.to_s} #{@second.to_s})"
  end

  # Bytecode emitter for an expression (postorder traversal of parse tree)
  def emit
    # emit LHS, RHS, opcode
    @first.emit << @second.emit << OPCODES[@op]
  end
end

# Compile and print out parse tree for expressions
class Compiler
  # Creates bytecodes from an arithmatic expression
  def self.compile(expr)
    self.mangle(expr).emit.flatten
  end

  # Prints a representation of the parse tree as an S-Expression
  def self.explain(expr)
    self.mangle(expr).to_s
  end

private
  # Name-mangles an expression so we create a parse tree when calling
  # Kernel#eval instead of evaluating the expression:
  #   [number] => [number].to_const()
  def self.mangle(expr)
    eval(expr.gsub(/\d+/) {|s| "#{s}.to_const()"})    
  end  
end
