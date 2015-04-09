# Read postfix from args or stdin
# Print an infix solution *without* paranthesis
postfix = ARGV.empty? ? $stdin.read.split : ARGV
postfix = postfix.map{ | ele | Integer( ele ) rescue ele }
stack = []
postfix.each do | ele |
  case ele
    when Integer
      stack << ele
    else
      rhs = stack.pop
      stack[ -1 ] = stack[ -1 ].send( ele, rhs )
    end
end
puts stack.first.to_s
