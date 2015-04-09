#!/usr/bin/ruby
# This week's quiz is to write a converter to and from Roman numerals.
#
# The script should be a standard Unix filter, reading from files specified on the
# command-line or STDIN and writing to STDOUT.  Each line of input will contain
# one integer (between 1 and 3999) expressed as an Arabic or Roman numeral.  There
# should be one line of output for each line of input, containing the original
# number in the opposite format.
#
# For example, given the following input:
#
#        III
#        29
#        38
#        CCXCI
#        1999
#
# The correct output is:
#
#        3
#        XXIX
#        XXXVIII
#        291
#        MCMXCIX
#
# If you're not familiar with or need a refresher on Roman numerals, the rules are
# simple.  First, there are seven letters associated with seven values:
#
#        I = 1
#        V = 5
#        X = 10
#        L = 50
#        C = 100
#        D = 500
#        M = 1000
#
# You can combine letters to add values, by listing them largest to smallest from
# left to right:
#
#        II   is 2
#        VII  is 8
#        XXXI is 31
#
# However, you may only list three consecutive identical letters.  That requires a
# special rule to express numbers like 4 and 900.  That rule is that a single
# lower value may proceed a larger value, to indicate subtraction.  This rule is
# only used to build values not reachable by the previous rules:
#
#        IV is 4
#        CM is 900
#
# But 15 is XV, not XVX.
#
# After additional clarification it became clear that:
#
# IV is 4
# IX is 9
# XL is 40
# XC is 90
# CD is 4000
# CM is 900
#
# Those are the only cases where a lower value proceeds a bigger value.
# Hopefully that clears up my intentions.  Sorry for the confusion.

class Integer
	# Used for Integer to Roman conversion. (#roman)
	@@roman_values_assoc = %w(I IV V IX X XL L XC C CD D CM M).zip([1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000]).reverse

	# Used for Roman to Integer conversion. (Integer#roman)
	@@roman_values = @@roman_values_assoc.inject({}) { |h, (r,a)| h[r] = a; h }

	# Spits out the number as a roman number
	def roman
		return "-#{(-self).roman}" if self < 0
		return "" if self == 0
		@@roman_values_assoc.each do | (i, v) |	return(i+(self-v).roman) if v <= self	end
	end

	# Returns a roman number string
	def Integer.roman(roman)
		last = roman[-1,1]
		roman.reverse.split('').inject(0) { | result, c |
			if @@roman_values[c] < @@roman_values[last]
				result -= @@roman_values[c]
			else
				last = c
				result += @@roman_values[c]
			end
		}
	end
end

# The filter. Turns integers to roman numbers and roman numbers to integer. Everything else is left as it is.
ARGF.each do | line |
	puts case line
			 when /^(\d+)/:	       Integer($1).roman
			 when /^([IVXLCDM]+)/: Integer.roman($1)
			 else line
			 end
end
