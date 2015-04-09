########################################
#   Now let's do the thing we are here for.
# We will use idea of operator strength.
# Each operator has left and right strength.
# Binary  operation should "protect" itself with parentheses if there is stronger operator
# to the left or to the right. Two neighbor operators affect each other with strengths:
# one with left-strength (the one to the right) and another with right-strength
# (the one to the left)
#
OP_STRENGTH = {
  :left  => {'+'=>2, '-'=>2, '*'=>4, '/'=>4},
  :right => {'+'=>2, '-'=>3, '*'=>4, '/'=>5}
}

stack = []
gets.strip.split.each do |token|
  # puts "TOKEN '#{token.inspect}'"
  case token
  when '*', '+', '/', '-'
    stack << [stack.pop, token, stack.pop].reverse!
  else
    stack << token
  end
end

# Uncomment these line to see some sort of 'parse tree'
# require 'yaml'
# puts stack.to_yaml

def parenthesize(triplet, top_op_strength, side)
  if triplet.is_a? Array
    parenthesize(triplet[0], OP_STRENGTH[:left][triplet[1]], :right)
    parenthesize(triplet[2], OP_STRENGTH[:right][triplet[1]], :left)
    if OP_STRENGTH[side][triplet[1]] < top_op_strength
      triplet.push  ')'
      triplet.unshift '('
    end
  end
end

parenthesize(stack.last, 0, :right)

puts stack.flatten.join
