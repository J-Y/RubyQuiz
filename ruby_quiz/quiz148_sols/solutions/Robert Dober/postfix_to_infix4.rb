# Read postfix from args or stdin
# Print an infix solution with *some* paranthesis
# (the clever way?)

class Expression
  Priorities = {
    "**" => 2,
    "*" => 1, "/" => 1, "%" => 1,
    "+" => 0, "-" => 0,
    nil => 3
  }
  Commutative = %w[ * + ]
  attr_reader :text, :top_op
  def initialize text
    @top_op = nil
    @text = text
  end

  def apply op, rhs
    @text = parented_text( op ) +
      " #{op} " << rhs.parented_text( op, false )
    @top_op = op
  end

  def comm? op
    Commutative.include? op
  end

  def parented_text op, is_lhs=true
    my_prio = Priorities[ @top_op ]
    op_prio  = Priorities[ op ]
    return @text if op_prio < my_prio
    return "( #@text )" if op_prio > my_prio
    return @text if comm?( op ) || is_lhs
    "( #@text )"
  end

end
postfix = ARGV.empty? ? $stdin.read.split : ARGV
postfix = postfix.map{ | ele |
  Expression::Priorities[ ele ] ? ele : Expression.new( ele )
}
stack = []
postfix.each do | ele |
  case ele
    when Expression
      stack << ele
    else
      rhs = stack.pop
      stack[ -1 ].apply ele, rhs
    end
end

puts stack.first.text
