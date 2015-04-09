#
# hangman.rb - rq130
# Paul Prestidge <chronicstar@gmail.com>
# 2007-07-11
#

require 'enumerator'

module Hangman
	# The Guesser class represents an agent that, given a Word instance, will try
	# and figure it out using the minimum number of steps.  It uses a dictionary,
	# which is passed in to the constructor along with the word to solve.
	class Guesser
		# Create a new Guesser instance for the given Word.  You can also pass in a
		# relative or absolute path to a dictionary, which must be a file containing
		# one word per line.
		def initialize(word, dict='word.list')
			raise 'Dictionary file "%s" does not exist.' % [dict] unless File.exist?(dict)
			
			@word = word
			@dictionary = File.readlines(dict).map{|w| w.chomp}.select{|w| w.length==word.length}
			@letters = ('a'..'z').to_a
		end

		# Choose a letter and check if it exists in the word.  If we're certain we
		# know what the word is now, confirm it.
		#
		# This method also displays a description of the action on stdout along with
		# the number of remaining possibilities (or a list of them, if there are
		# only a few).
		def go!
			next_letter = check_next_letter
			
			raise 'Unknown word' if @dictionary.size == 0 # TODO: guess randomly?
			remaining_options = @dictionary.size > 10 ? "#{@dictionary.size} possibilities" : @dictionary.join(', ')
			puts '%2i: %1s => %*s => %s' % [@word.turns, next_letter, @word.length, @word, remaining_options]
			
			@word.guess(@dictionary.first) if @dictionary.size == 1
		end

		# Reorder the letters array, then take the first letter and check it against
		# the sample word.  If the letter appeared in our word, filter the
		# dictionary, removing words that are no longer consistent with our current
		# information.
		#
		# Returns the letter checked.
		def check_next_letter
			recalculate_letter_frequencies
			letter = @letters.shift
			@word.check_letter(letter)
			prune_dictionary
			
			letter
		end
		
		# This is the core of the Guesser's decision-making.  It reorders the
		# letters array from most likely to least likely, using some simple
		# heuristics.  The Guesser then uses this to decide which letter to
		# guess next.
		#
		# The aim is to select the letter which would eliminate as close to half
		# the remaining words as possible whether it is actually in the word or not.
		# It's not optimal but it works pretty well.
		def recalculate_letter_frequencies
			# Calculate, for each letter and position, how many words in the list
			# would remain if that combination was extant.
			totals = @dictionary.inject(Hash.new{|h,k| h[k] = [0]*@word.size}) do |hash,word| 
				word.split('').each_with_index do |letter,idx|
					hash[letter][idx] += 1 if @word[idx] == ?.
				end
				
				hash
			end
			
			proportions = Hash[*totals.map { |k,v| [k, v.inject(0){|s,c|s+(0.5-(c.to_f / @dictionary.size)).abs} / v.size]}.flatten]
			
			# Delete letters that don't appear in any remaining dictionary words
			@letters.delete_if { |l| !proportions.include?(l) }
			
			# Reorder the array based on the proportions array
			@letters = @letters.sort_by { |l| proportions[l] }
		end
		
		# Removes all items from our dictionary that don't fit with what
		# we know about the word.
		def prune_dictionary
			@dictionary.delete_if { |w| w !~ pattern }
		end
		
		# Returns a regular expression encapsulating the criteria that the word
		# must meet, given what we currently know about it.
		def pattern
			Regexp.new('^'+@word.gsub('.',"[#{@letters.join}]")+'$')
		end
	end

	# The Word class represents a Hangman word.  It starts out initially as a
	# series of periods, and each time a successful check_letter is performed more
	# letters are made visible.
	#
	# The number of total letters and failed letters are available using 
	# Word#turns and Word#fails, respectively.
	class Word < String
		attr_reader :turns, :fails
		
		def initialize(word)
			raise 'Word must contain only alphabetic characters' unless word =~ /^[a-z]+$/i
			
			@word = word.downcase
			@turns, @fails = 0, 0
			super '.' * word.length
		end
		
		# Reveal all instances of the given letter.  Counts as a failed guess
		# if the word does not contain any of that letter.
		#
		# Returns the total number of letters revealed.
		def check_letter(letter)
			total = @word.split('').enum_with_index.inject(0) do |t,(l,i)| 
				if l == letter
					self[i,1] = l 
					t += 1
				end
				
				t
			end
			
			@turns += 1
			@fails += 1 if total == 0
			
			total
		end
		
		# Make a guess at the complete word.
		#
		# Currently does not impose any penalties for incorrect guesses, but perhaps
		# they should exhaust a turn or something similar.
		def guess(word)
			replace(word) if word == @word
		end
		
		# Returns true if the word has been solved completely.
		def solved?
			self == @word
		end
	end
end

# If this file is called directly, it will create an agent that guesses the word
# passed in ARGV[0].  It will continue until it has solved the word or until it
# has six incorrect guesses.
#
# Here's some examples of execution on my work PC (2.7ghz, 768mb RAM) with a
# dictionary containing 264k words (total size 2.59mb):
#
#  1: i => ..........i.. => 1411 possibilities
#  2: e => .e........i.. => 59 possibilities
#  3: a => .e......a.i.. => 11 possibilities
#  4: r => .e.....ra.i.. => demonstrating, demonstration
#  5: n => .e..n..ra.i.n => demonstration
# Solved the word in 5 turns with 0 wrong guesses.  The word was "demonstration".
# Execution time: 3.8 seconds.
#
#  1: e => ......e => 2180 possibilities
#  2: a => .a....e => 271 possibilities
#  3: i => .a....e => 104 possibilities
#  4: o => .a.o..e => 18 possibilities
#  5: c => .a.o..e => baronne, baroque, galoshe, garotte, gavotte, jalouse, kagoule, zamouse
#  6: t => .a.otte => garotte, gavotte
#  7: v => .a.otte => garotte
# Solved the word in 7 turns with 3 wrong guesses.  The word was "garotte".
# Execution time: 6.1 seconds.
#
# It reports to stdout.
if $0 == __FILE__
	word = Hangman::Word.new($*.shift || 'zeitgeist')
	ai = Hangman::Guesser.new(word)
	start_time = Time.now
	
	ai.go! until word.fails >= 6 or word.solved?
	
	if word.solved?
		puts 'Solved the word in %i turns with %i wrong guesses.  The word was "%s".' % [word.turns, word.fails, word]
	else
		puts 'Could not solve the word in %i turns with %i wrong guesses.' % [word.turns, word.fails]
	end
	
	puts 'Execution time: %.1f seconds.' % [Time.now-start_time]
end