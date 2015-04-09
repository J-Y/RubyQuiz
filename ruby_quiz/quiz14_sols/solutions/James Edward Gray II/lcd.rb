#!/usr/bin/env ruby

DIGITS = [
	[ " - ",
	  "| |",
	  "   ",
	  "| |",
	  " - " ],
	[ "   ",
	  "  |",
	  "   ",
	  "  |",
	  "   " ],
	[ " - ",
	  "  |",
	  " - ",
	  "|  ",
	  " - " ],
	[ " - ",
	  "  |",
	  " - ",
	  "  |",
	  " - " ],
	[ "   ",
	  "| |",
	  " - ",
	  "  |",
	  "   " ],
	[ " - ",
	  "|  ",
	  " - ",
	  "  |",
	  " - " ],
	[ " - ",
	  "|  ",
	  " - ",
	  "| |",
	  " - " ],
	[ " - ",
	  "  |",
	  "   ",
	  "  |",
	  "   " ],
	[ " - ",
	  "| |",
	  " - ",
	  "| |",
	  " - " ],
	[ " - ",
	  "| |",
	  " - ",
	  "  |",
	  " - " ]
]

def scale( num, size )
	bigger = [ ]
	num.each do |l|
		row = l.dup
		row[1, 1] = row[1, 1] * size
		if row =~ /\|/
			size.times { bigger << row }
		else
			bigger << row
		end
	end
	bigger
end

s = 2
if ARGV.size >= 2 and ARGV[0] == '-s' and ARGV[1] =~ /^[1-9]\d*$/
	ARGV.shift
	s = ARGV.shift.to_i
end

unless ARGV.size == 1 and ARGV[0] =~ /^\d+$/
	puts "Usage:  #$0 [-s SIZE] DIGITS"
	exit
end
n = ARGV.shift

num = [ ]
n.each_byte do |c|
	num << [" "] * (s * 2 + 3) if num.size > 0
	num << scale(DIGITS[c.chr.to_i], s)
end

num = ([""] * (s * 2 + 3)).zip(*num)
num.each { |l| puts l.join }
