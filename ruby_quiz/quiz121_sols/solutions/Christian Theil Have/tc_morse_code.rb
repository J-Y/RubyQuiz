def test_word2morse
	m = Morse.new
	raise unless  m.word2morse("sofia") == "...---..-....-"
end

def test_first_letters
	m = Morse.new
	raise unless m.first_letters(".", 0) == [ "." ];
	raise unless m.first_letters("--.--..--.-.", 0) == ["--", "-", "--.", "--.-"]
end

def test_morse2words
	m = Morse.new
	sofia = "...---..-....-"
	solutions = m.morse2words(sofia)
	solutions.each do |s|
		if m.word2morse(s) != sofia
			puts "bad solution: #{s}"
			puts "yields #{m.word2morse(s)} in morse"
                       raise
		end
	end
end

test_word2morse
test_first_letters
test_morse2words
