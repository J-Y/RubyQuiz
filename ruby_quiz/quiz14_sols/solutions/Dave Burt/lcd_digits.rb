#!/usr/bin/ruby
#
# LCD-like ASCII-art digits
#
# A response to Ruby Quiz of the Week #14 [ruby-talk:125427]
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 8 Jan 2004
#
# Last modified: 10 Jan 2004
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.
#
# Example:
# % lcd_digits.rb -s 3 1234567890
#        ---   ---         ---   ---   ---   ---   ---   ---
#     |     |     | |   | |     |         | |   | |   | |   |
#     |     |     | |   | |     |         | |   | |   | |   |
#     |     |     | |   | |     |         | |   | |   | |   |
#        ---   ---   ---   ---   ---         ---   ---
#     | |         |     |     | |   |     | |   |     | |   |
#     | |         |     |     | |   |     | |   |     | |   |
#     | |         |     |     | |   |     | |   |     | |   |
#        ---   ---         ---   ---         ---   ---   ---
#


#   [6]
# [5] [4]
#   [3]
# [2] [1]
#   [0]
DigitCode = {
	0 => 0b1110111,
	1 => 0b0010010,
	2 => 0b1011101,
	3 => 0b1011011,
	4 => 0b0111010,
	5 => 0b1101011,
	6 => 0b1101111,
	7 => 0b1010010,
	8 => 0b1111111,
	9 => 0b1111011,
	:E => 0b1101101
}
VBar = [' ', '|']
HBar = [' ', '-']

def lcd_digit(digit, size = 2)
	code = DigitCode[digit.to_i] || DigitCode[:E]

	' ' + HBar[code[6]] * size + " \n" +
	(VBar[code[5]] + ' ' * size + VBar[code[4]] + "\n") * size +
	' ' + HBar[code[3]] * size + " \n" +
	(VBar[code[2]] + ' ' * size + VBar[code[1]] + "\n") * size +
	' ' + HBar[code[0]] * size + " \n"
end

# like the unix paste command, maps the first line of each string in the given
# array to the first line of the result, horizontally separated by delim
def paste(array_of_strings, delim = ' ')
	result = ''
	# arr is an array of arrays of lines
	arr = array_of_strings.map {|string| string.split /\n/ }
	while arr.any? {|elem| not elem.empty? } do
		result << arr.map {|elem| elem.shift }.join(delim) << "\n"
	end
	result
end

if $0 == __FILE__
	# process -s SIZE parameter
	if ARGV.include? '-s'
		s_index = ARGV.index('-s')
		size = ARGV[s_index + 1].to_i
		ARGV.delete_at s_index + 1
		ARGV.delete_at s_index
	end
	if !size || size < 1
		size = 2
	end
	
	# process NUMBER parameter
	number = ARGV[0].to_s.scan(/\d/)
	
	# quit if parameters aren't correct
	if number.empty? || ARGV.length > 1
		puts "Usage: #{$0} [-s SIZE] NUMBER"
		exit
	end
	
	# lcd_digit() the number, then paste() the digits side-by-side
	puts paste(number.map {|digit| lcd_digit(digit, size) })
	
	exit
end
