#!/usr/bin/env ruby

#
# A simple class for managing a filter that prevents to use
# of a given _banned_words_ list.
#
class LanguageFilter
	#
	# Create a new LanguageFilter object that will
	# disallow _banned_words_.
	# Accepts a list of words, arrays of words,
	# or a combination of the two.
	#
	def initialize( *banned_words )
		@banned_words = banned_words.flatten.sort
		@clean_calls = 0
	end
	
	# A count of the calls to <i>clean?</i>.
	attr_reader :clean_calls
	
	#
	# Test if provided _text_ is allowable by this filter.
	# Returns *false* if _text_ contains _banned_words_,
	# *true* if it does not.
	#
	def clean?( text )
		@clean_calls += 1
		@banned_words.each do |word|
			return false if text =~ /\b#{word}\b/
		end
		true
	end
	
	#
	# Verify a _suspect_words_ list against the actual
	# _banned_words_ list.
	# Returns *false* if the two lists are not identical or
	# *true* if the lists do match.
	# Accepts a list of words, arrays of words,
	# or a combination of the two.
	#
	def verify( *suspect_words )
		suspect_words.flatten.sort == @banned_words
	end
end

# my algorithm
def isolate( list, test )
	if test.clean? list.join(" ")
		Array.new
	elsif list.size == 1
		list
	else
		left, right = list[0...(list.size / 2)], list[(list.size / 2)..-1]
		isolate(left, test) + isolate(right, test)
	end
end

# test code
words = ARGF.read.split " "
filter = LanguageFilter.new words.select { rand <= 0.01 }

start = Time.now
banned = isolate words, filter
time = Time.now - start

puts "#{words.size} words, #{banned.size} banned words found"
puts "Correct?  #{filter.verify banned}"
puts "Time taken: #{time} seconds"
puts "Calls: #{filter.clean_calls}"
puts "Words:"
puts banned.map { |word| "\t" + word }
