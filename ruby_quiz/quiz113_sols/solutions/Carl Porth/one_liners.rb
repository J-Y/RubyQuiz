# * Given a Numeric, provide a String representation with commas inserted between each set of three digits in front of the decimal.
quiz.to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse

# * Given a nested Array of Arrays, perform a flatten()-like operation that removes only the top level of nesting.
quiz.inject([]) { |mem, var| var.is_a?(Array) ? mem+var : mem+[var] }

# * Shuffle the contents of a provided Array.
quiz.sort{rand}

# * Given a Ruby class name in String form, fetch the actual class object.
eval quiz

# * Insert newlines into a paragraph of prose (provided in a String) so lines will wrap at 40 characters.
quiz.scan(/(.{1,40})(?:\s+|$)/m).join("\n")

# * Given an Array of String words, build an Array of only those words that are anagrams of the first word in the Array.
word = quiz.shift.split('').sort; quiz.select { |e| e.split('').sort == word }

# * Convert a ThinkGeek t-shirt slogan (in String form) into a binary representation (still a String).
quiz.gsub(/\S/) { |l| l.unpack('U')[0].to_s(2) }.gsub(' ', "\n")

# * Provided with an open File object, select a random line of content.
quiz.readlines.sort{rand}.first

# * Given a wondrous number Integer, produce the sequence (in an Array).
q=[n=quiz]; q << (n = n%2 == 0 ? n/2 : 3*n+1) until n==1; q

# * Convert an Array of objects to nested Hashes...
quiz.reverse.inject { |mem, var| {var => mem} }