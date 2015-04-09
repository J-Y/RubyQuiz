#! /usr/bin/ruby -w

class Array
	def rand_elem
		self[rand(size)]
	end
end

# Open and read the dictionary.
dict = IO.read("/usr/share/dict/words")

# Pick a random word with 6 letters.
baseWord = dict.scan(/^[a-z]{6}$/).rand_elem

# Find words that use the same letters
selectedWords = dict.scan(/^[#{baseWord}]{3,6}$/)

# Display the words.
puts baseWord + ":\n\t" + selectedWords.join("\n\t")