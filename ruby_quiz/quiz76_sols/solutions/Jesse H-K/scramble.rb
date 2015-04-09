#By Jesse H-K
#On the date of Sunday April 23, 2006

class String
	#Take a string, and scramble the center of each word.
	def scramble
		#find each word and replace it with...
		gsub(/\w+/) do |word|
			if (1..3) === word.length
				#..the word if it's length is 1, 2, or 3. These words cannot be scrambled.
				word
			else
				#...the first character, plus the scrambled middle, and ending with the last character.
				word[0].chr + word[1..(-2)].scan(/./).sort_by { rand }.join + word[-1].chr
			end
		end
	end
end

while str = gets
	puts str.scramble
end
