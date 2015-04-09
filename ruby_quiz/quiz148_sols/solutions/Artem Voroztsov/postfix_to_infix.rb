#########################################
# OK
# Let's start with simple one.
# This one just does the job  without removing odd parentheses

stack = []
gets.strip.split.each do |token|
  case token
  when '*', '+', '/', '-'
    stack << [')', stack.pop, token, stack.pop, '('].reverse!
  else
    stack << token
  end
end

puts stack.flatten.join
