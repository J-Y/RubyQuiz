#!/usr/bin/ruby
# author: Yoan Blanc <yoan at dosimple.ch>
# revision: 20080118

# Quiz153: http://www.rubyquiz.com/quiz153.html
#
# a script that finds the longest repeated substring
# in a given text.

text = STDIN.read

match = ""

## sweet way
0.upto(text.length-1) do |i|
	# find a repeatition
	j = text[(i+1)..text.length-1].index(text[i..i])
	until j.nil?
		# found offset is too far away from the first occurence
		break if (j-i) > (text.length-j-1)
		
		# real position
		j += 1
		
		# test if there is a match (longer than the previous one)
		if (j-i) > match.length and text[i..j-1] == text[j..j+(j-i)-1]
				match = text[i..j-1]
		end
		
		# any letters remaining?
		k = text[j+1..text.length-1].index(text[j..j])
		# if yes, j is this new letter.
		j = k.nil? ? k : j+k
	end
end

puts match