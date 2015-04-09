# 
# Given a Numeric, provide a String representation with commas inserted between
# each set of three digits in front of the decimal.  For example, 1999995.99
# should become "1,999,995.99".
# 
quiz.to_s.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/,"\\1,").reverse

# 
# Given a nested Array of Arrays, perform a flatten()-like operation that
# removes only the top level of nesting.  For example, [1, [2, [3]]] would
# become [1, 2, [3]].
# 
quiz.inject(Array.new) { |arr, a| arr.push(*a) }

# Shuffle the contents of a provided Array.
quiz.sort_by { rand }

# 
# Given a Ruby class name in String form (like
# "GhostWheel::Expression::LookAhead"), fetch the actual class object.
# 
quiz.split("::").inject(Object) { |par, const| par.const_get(const) } 

#
# Insert newlines into a paragraph of prose (provided in a String) so lines will
# wrap at 40 characters.
# 
quiz.gsub!(/(.{1,40}|\S{41,})(?: +|$\n?)/, "\\1\n")

# 
# Given an Array of String words, build an Array of only those words that are
# anagrams of the first word in the Array.
# 
quiz.select { |w| w.split("").sort == quiz.first.split("").sort }

# 
# Convert a ThinkGeek t-shirt slogan (in String form) into a binary
# representation (still a String).  For example, the popular shirt "you are
# dumb" is actually printed as:
# 
#   111100111011111110101
#   110000111100101100101
#   1100100111010111011011100010
# 
quiz.split("").map { |c| c == " " ? "\n" : c[0].to_s(2) }.join

# Provided with an open File object, select a random line of content.
quiz.inject { |choice, line| rand < 1/quiz.lineno.to_f ? line : choice }

# 
# Given a wondrous number Integer, produce the sequence (in an Array).  A
# wondrous number is a number that eventually reaches one, if you apply the
# following rules to build a sequence from it.  If the current number in the
# sequence is even, the next number is that number divided by two.  When the
# current number is odd, multiply that number by three and add one to get the
# next number in the sequence.  Therefore, if we start with the wondrous number
# 15, the sequence is [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16,
# 8, 4, 2, 1].
# 
Hash.new { |h, n| n == 1 ? [1] : [n] + h[n % 2 == 0 ? n/2 : n*3+1] }[quiz]

# 
# Convert an Array of objects to nested Hashes such that %w[one two three four
# five] becomes {"one" => {"two" => {"three" => {"four" => "five"}}}}.
# 
quiz.reverse.inject { |res, wrap| {wrap => res} }
