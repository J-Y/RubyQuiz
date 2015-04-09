class VerbalArithmetic

 # Parse given equation into lvalues (words on the left-hand side of the '=' that
 # are to be added together) and an rvalue (the single word on thep right-hand side)
 def parse_equation (equation)
   lvalues = equation.split("+")
   rvalue = lvalues[-1].split("=")
   lvalues[-1] = rvalue[0] # Get last lvalue
   rvalue = rvalue[1]      # Get rvalue

   return lvalues, rvalue
 end

 # Brute force a solution by trying all possible combinations
 def find_solution(lvalues, rvalue)

   # Form a list of all letters
   words = Marshal::load(Marshal::dump(lvalues))
   words.push(rvalue)
   letters = {}
   words.each do |word|
     word.split("").each do |letter|
       letters[letter] = letter if letters[letter] == nil
     end
   end

   # Format l/r values to ease solution analysis below
   lvalues_formatted = []
   lvalues.each {|lval| lvalues_formatted.push(lval.reverse.split(""))}
   rvalue_formatted = rvalue.reverse.split("")

   # For all unordered combinations of numbers...
   for i in Combinations.get(10, letters.values.size)

     # For all permutations of each combination...
     perm = Permutation.for(i)
     perm.each do |p|

       # Map each combination of numbers to the underlying letters
       map = {}
       parry = p.project
       for i in 0...letters.size
         map[letters.values[i]] = parry[i]
       end

       # Does this mapping yield a solution?
       if is_solution?(lvalues_formatted, rvalue_formatted, map)
         return map
       end
     end
   end

   nil
 end

 # Determines if the given equation may be solved by
 # substituting the given number for its letters
 def is_solution?(lvalues, rvalue, map)

   # Make sure there are no leading zero's
   for lval in lvalues
     return false if map[lval[-1]] == 0
   end
   return false if map[rvalue[-1]] == 0

   # Perform arithmetic using the mappings, and make sure they are valid
   remainder = 0
   for i in 0...rvalue.size
     lvalues.each do |lval|
       remainder = remainder + map[lval[i]] if map[lval[i]] != nil # Sum values
     end

     return false if (remainder % 10) != map[rvalue[i]] # Validate digit
     remainder = remainder / 10                         # Truncate value at this place
   end

   true
 end
end

# Finally, this code puts everything together:

va = VerbalArithmetic.new
lvalues, rvalue = va.parse_equation("send+more=money")
map = va.find_solution(lvalues, rvalue)

puts "Solution: ", map if map != nil
