#!/usr/bin/env ruby
# fixer.rb

$stack = []
$exit_bad = false

def pop_check(token)
	$exit_bad = $stack.empty? || $stack.pop != token	
	nil
end

def seq(x)
	"#{expr(x)}#{seq(x)}" unless x.empty?
end

def expr(x)
	c = x.shift
	if !c.nil?
		case c
			when '['
				$stack.push c
				['[', expr(x), ']']
			when '{'
				$stack.push c
				['{', expr(x), '}']
			when '('
				$stack.push c
				['(', expr(x), ')']
			when ']'
				pop_check '['
			when '}'
				pop_check '{'
			when ')'
				pop_check '('
			else
				"#{c}#{expr(x)}"
		end
	end
end

input = ARGV[0]
abort("empty input") if input.nil? || input.empty?

tokens = input.split('')
output = seq(tokens)

puts output.to_s
abort if $exit_bad || !$stack.empty?

=begin rdoc

:section: Usage

fixer.rb input_str

Where input_str can be anything. The input_str is output with possible
modifications. Any left '[', '{' or '(' in the input are paired with their
matching right token. If the input string does not contain balanced pairs of
brackets, braces or parens, the correct sequence is inferred and output. If
an error occurs, an exit status of 1 is returned. If the input is empty,
an exit status of 1 is output and 'empty input' is written to stderr.

:section: About the solution

At first blush, this seems a straightforward paren balancing problem, with the
twist that there are different kinds of parenthesis. My first attempt was
a simple stack based attempt where I pushed the left side tokens and then popped
the stack when I encountered a right side token. If the right side matched
its corresponding left side we continued, else if it didn't match or the
stack was empty I flagged an error and exited. If it reached the end of the
input and the stack was not empty it was an error.

The extra credit part of fixing the input was more challenging. I started out
with a traditional recursive descent parser. I implied the grammer was something
like this (forgive my bad BNF style notation:)
seq : expr seq
expr : term
     | '[' expr ']'
     | '{' expr '}'
     | '(' expr ')'
term : <current char>

After refactoring, I was left with the simple #seq and #expr with the case
statement you see here. It worked for every test case I could throw at it.
Which left me to wonder how to detect the errors in the input. Finally, I merged
in the original stack balancer from my first attempt.

The corrected sequence is inferred by left precedence. I.e. Any left
tokens are assumed to be correct, and all right tokens are ignored in
favor of the grammar
above. Ross didn't state what the correct sequence was for his 2 error
conditions, so I went with this interpretation.

=end
