# Read postfix from args or stdin
# Print an infix solution with *some* paranthesis
# the stupid ( and expensive ) way.

class Expression
  Combinations = [
    ["", "", "", ""],
    ["( ", " )", "", ""],
    ["", "", "( ", " )"],
    ["( ", " )", "( ", " )"]
  ]
  attr_reader :text, :value
  def initialize text
    @value = Integer( text )
    @text = text
  end
  def apply op, rhs
    new_text = "#@text #{op} #{rhs.text}"
    @value = @value.send( op, rhs.value )
    Combinations.each do | parens |
      txt = ["", @text, " #{op} ", rhs.text ].
        zip( parens ).flatten.join
        if eval( txt ) == @value then
          return @text = txt
        end
    end
    raise RuntimeError, "ooops"
  end
end

postfix = ARGV.empty? ? $stdin.read.split : ARGV
postfix = postfix.map{ | ele | Expression.new( ele ) rescue ele }
stack = []
postfix.each do | ele |
  case ele
    when Expression
      stack << ele
    else
      rhs = stack.pop
      stack.last.apply ele, rhs
    end
end

puts stack.first.text
