class Morse
	@@alpha = {
		"a" => ".-",
		"b" => "-...",
		"c" => "-.-.",
		"d" => "-..",
		"e" => ".",
		"f" => "..-.",
		"g" => "--.",
		"h" => "....",
		"i" => "..",
		"j" => ".---",
		"k" => "-.-",
		"l" => ".-..",
		"m" => "--",
		"o" => "---",
		"p" => ".--.",
		"q" => "--.-",
		"r" => ".-.",
		"s" => "...",
		"t" => "-",
		"u" => "..-",
		"v" => "...-",
		"w" => ".--",
		"x" => "-..-",
		"y" => "-.--",
		"z" => "--.."
	}

	def initialize
		# Reverse index the array
		@rev = {}
		@@alpha.each { |k,v| @rev[v] = k.to_s }
	end

	# Returns all letters matching the morse str at this pos
	def first_letters(morse, pos)
	  letters = []
	  @rev.keys.each { |k|  letters << k unless morse[pos..-1].scan(/^#{k.gsub(".","\\.")}.*/).empty? }
	
	  letters
	end

	# Returns an array of words that matches 'morse' string
	# It's basically a recursive function with bactracking
	def morse2words(morse, pos = 0 , seen = "")
		solutions = []
		first_letters(morse, pos).each do |l|
			if morse.length == pos + l.length
				solutions << "#{seen}#{@rev[l]}"
			else
				result = morse2words(morse,(pos+l.length),"#{seen}#{@rev[l]}")
				solutions += result
			end
		end

		solutions
	end

	# Converts a word to a morse string, used for testing
	def word2morse(word)
		morse = ""
		word.each_byte { |b| morse << @@alpha[b.chr] }

		morse
	end
end
