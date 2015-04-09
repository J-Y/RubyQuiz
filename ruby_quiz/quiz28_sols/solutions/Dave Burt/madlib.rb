#
# This function is the solution to the quiz. It takes a madlib string, fills
# the placeholders using input() (defined below) and returns the result.
#
def madlib(string)
 names = {}
 string.gsub /\(\(.*?\)\)/ do |token|
  a, b = *token[2...-2].split(':')
  if names.has_key? a
   names[a]
  elsif b
   names[a] = input(b)
  else
   input(a)
  end
 end
end

#
# Ask the user for thing, and return the user's response.
#
def input(thing)
 print "Enter #{thing}: "
 gets.chomp
end

#
# Here's another interface - you can run this ruby script from the command 
line
# and pass it a madlib filename as an argument, or pass the text on STDIN.
#
if $0 == __FILE__
 puts madlib(ARGF.read)
end
