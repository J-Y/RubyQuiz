# Ruby Quiz #148: Postfix to Infix
# http://www.rubyquiz.com/quiz148.html
#
# Solution by Aaron Suggs, aaron / zenbe.com

# Some elementary arithmetic conventions
ORDER_OF_OPERATORS = {
 '+'  => 0,
 '-'  => 0,
 '/'  => 1,
 '*'  => 1,
 '^'  => 2, # Ooh, exponentiation
 '**' => 2
}

# Recursive infixer
# Takes a stack (array), and order of its parent operator (Fixnum);
# returns string of infix expression
def r_infix(stack, parent_order)
 term = stack.pop
 if term =~ /\d/
   term.to_s
 else
   order = ORDER_OF_OPERATORS[term]
   # To preserve order of terms, compute right side before left
   right, left = r_infix(stack, order), r_infix(stack, order)
   str = "#{left} #{term} #{right}"
   order < parent_order ? "(#{str})" : str # add parens if needed
 end
end


begin
 # Get the postfix stack from ARGV
 stack = ARGV.first.split(/\s+/)
 # Converts postfix string to infix w/ minimal parentheses
 result = r_infix(stack, -1)
 raise("Stack not empty") unless stack.empty?
 puts result
rescue
 puts "Malformed postfix expression"
end

