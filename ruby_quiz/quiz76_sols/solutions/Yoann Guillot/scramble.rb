# 1st try:
# does not scramble abcd123, which may or not be a good thing
# no support for accented characters
# _ is considered a letter
#puts ARGF.read.gsub(/\b(?=\D+\b)(\w)(\w+)(?=\w\b)/) { $1 + $2.split('').sort_by{rand}.join }

class String
	# returns the string with characters randomly placed
	def randomize
		split('').sort_by{rand}.join
	end

	# character class to identify a word's letter
	# arbitrarily ripped from iso-8859-1
	WordChars = '[a-zA-Z\xc0-\xd6\xd8-\xf6\xf8-\xfd\xff]'
	
	# randomizes each word (defined by +chars+), leaving alone the
	# first and last letters
	# uses a default argument to fit in 80 cols :)
	def scramble_words(chars = WordChars)
		gsub(/(#{chars})(#{chars}+)(?=#{chars})/) { $1 + $2.randomize }
	end
end

puts ARGF.read.scramble_words if __FILE__ == $0
