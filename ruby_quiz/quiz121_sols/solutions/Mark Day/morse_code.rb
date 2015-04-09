#
# Ruby Quiz #121: Morse Code
#
# The example Morse code from the quiz is: ...---..-....-
#

#
# MORSE_SYMS: A dictionary mapping letters to their morse code.
#
MORSE_SYMS = { "a", ".-", "b", "-...", "c", "-.-.", "d", "-..",
	"e", ".", "f", "..-.", "g", "--.", "h", "....", "i", "..",
	"j", ".---", "k", "-.-", "l", ".-..", "m", "--", "n", "-.",
	"o", "---", "p", ".--.", "q", "--.-", "r", ".-.", "s", "...",
	"t", "-", "u", "..-", "v", "...-", "w", ".--", "x", "-..-",
	"y", "-.--", "z", "--.." }

#
# morse_words: Given a string of Morse code (s), return an array
# of strings of letters which have the same morse code.
#
# The technique is recursive: attempt to match the start of the
# Morse code string to the Morse code for each letter.  If it
# matches, then return an array of words starting with that letter,
# and followed by all possible strings made up from the remaining
# Morse code.
#
def morse_words(s)
	words = []
	MORSE_SYMS.each_pair do |letter, morse|
		#
		# If the remaining string exactly matches a letter, then
		# add that letter (by itself) as a result.  This is how the
		# recursion "bottoms out."
		#
		if s == morse
			words << letter
			next
		end
		
		#
		# Does the Morse code for the current letter match the start
		# of the Morse code string?
		#
		l = morse.length
		if s[0,l] == morse
			#
			# Generate the possibilities starting with the current letter.
			#
			morse_words(s[l..-1]).each do |w|
				words << letter+w
			end
		end
	end
	return words
end

#
# to_morse: Convert a word into its Morse code equivalent by splitting
# the word into individual letters, mapping each letter, and rejoining
# them with the given separator.
#
def to_morse(word, sep="|")
	word.scan(/./).map { |c| MORSE_SYMS[c] }.join(sep)
end

if __FILE__ == $0
	#
	# The command line arguments are paths to files containing
	# dictionary words separated by whitespace.  For example,
	# pass /usr/share/dict/words.
	#
	dictionary = []
	ARGV.each do |path|
		# puts "Reading #{path}..."
		dictionary.concat(open(path).read.split)
	end
	
	#
	# The following words were translations from the example Morse
	# code string, but not in my dictionaries, so add them so we
	# can test the "word in dictionary" case.
	#
	dictionary << "sofia"
	dictionary << "eugenia"
	
	#
	# Read Morse code strings from standard input, and print possible
	# words to standard output.
	#
	$stdin.each do |morse|
		words = morse_words(morse.chomp)
		words.sort!		# Sorted output is easier to scan
		
		#
		# Find the length of the longest Morse code string
		# so that we can line up columns nicely.
		#
		morse_max = words.map { |w| to_morse(w).length }.max
		
		#
		# Separate the words into two lists: those words which are
		# in the dictionary, and those that aren't.
		#
		dict_words = words & dictionary
		non_dict_words = words - dict_words
		
		#
		# Print the words.  I chose to print the dictionary words
		# last, so they'd be easier to spot.
		#
		puts "Non-dictionary words:"
		non_dict_words.each do |word|
			print to_morse(word).ljust(morse_max), " => ", word, "\n"
		end

		puts "Dictionary words:"
		dict_words.each do |word|
			print to_morse(word).ljust(morse_max), " => ", word, "\n"
		end
	end
end
