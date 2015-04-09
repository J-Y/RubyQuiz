#! /usr/bin/ruby -w

class Array
	def rand_elem
		self[rand(size)]
	end
	
	def english_join
		self[0...-1].join(', ') + ', and ' + self[-1]
	end
end

class String
	def letters
		unless $DEBUG
			split(//).uniq.sort_by{rand}
		else
			split(//)
		end
	end
end

class Game
	@@dict = nil
	
	def initialize
		# Open and read the dictionary.
		@@dict ||= IO.read("/usr/share/dict/words")
		
		@points = 0
		@round = 1
	end

	def play
		# Pick a random word with 6 letters.
		baseWord = @@dict.scan(/^[a-z]{6}$/).rand_elem

		# Find words that use the same letters
		selectedWords = @@dict.scan(/^[#{baseWord}]{3,6}$/)
		
		# Initialize word list & continue var.
		guessed = []
		continue = false
		
		# Display banner
		puts "",
			"Round #{@round}:",
			"Enter the 5 longest words you can make from the letters #{baseWord.letters.english_join}.",
			"Invalid and repeated words count towards the 5 words but subtract points.",
			""
		
		# Gather all the points, calculate the score, and see if the player should go to the next round.
		5.times do
			print "#{@points}\t"
			word = gets.chomp.downcase
			if !guessed.include?(word) && selectedWords.include?(word)
				@points += word.length ** 3
				guessed << word
				continue = true if word.length == 6
			else
				@points -= word.length ** 3
			end
		end
		
		# Go on to the next round or lose.
		if continue
			@round += 1
			play
		else
			puts "Sorry, you didn't get a 6 letter word.  You got #{@points} points, however."
		end
	end
end

Game.new.play