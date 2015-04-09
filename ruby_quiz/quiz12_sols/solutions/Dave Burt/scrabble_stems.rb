#!/usr/bin/ruby

# Scrabble Stems finder
# A response to Ruby Quiz #12
#
# usage: scrabble_stems.rb dictionary [n] [--downcase]
# where dictionary is a text file with words in it, and n is the minimum number of letters
# that need to be able to be added to a stem to make real words for you to care about the stem.
#
# Author: Dave Burt <dave at burt.id.au>
# Created: 19 Dec 2004
# Last Updated: 20 Dec 2004
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is not
#             disallowed. Credit's required if you use any of my code.
#             I'd appreciate seeing any modifications you make to it.

start_time = Time.new

class Array
	def reject_at(index)
		result = dup
		result.delete_at(index)
		result
	end
end

DICTIONARY_FILE = ARGV[0]
WORD_LENGTH = 7
THRESHOLD = (ARGV[1] || 6).to_i
DOWNCASE = ARGV.include? '--downcase'


# Collect sets of 6 letters, mapping these to sets of 7 letters that make words
# Map each set of 7 letters to one word they make
# stems[0..] => letters[1..7] => word[1]
stems = {}
File.new(DICTIONARY_FILE).each_line do |line|
	line.scan(/\w+/).each do |word|
		next if word.length != WORD_LENGTH
		word.downcase! if DOWNCASE
		letters = word.scan(/./).sort
		WORD_LENGTH.times do |i|
			stem = letters.reject_at(i-1)
			stems[stem] ||= {}
			stems[stem][letters] ||= word
		end
	end
end

# Discard stems with too few words
stems.reject! do |stem, letters|
	letters.length < THRESHOLD
end

# Display results, ordered by reverse count and alphabetically, with 7-letter words
stems.values.map{|a| a.length }.uniq.sort.reverse.each do |count|
	stems.keys.sort.each do |stem|
		if stems[stem].length == count
			print "#{stem.join}\t#{count.to_s}\t"
			i = 0
			stems[stem].each_value do |word|
				i += 1
				print word
				print i % 8 == 0 ? "\n\t\t" : "\t"
			end
			puts
		end
	end
end

# Display time elapsed. That seems to be a bit of a takling point around here.
print Time.new - start_time, ' seconds elapsed'
