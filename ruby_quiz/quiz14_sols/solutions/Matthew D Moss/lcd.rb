#!/usr/bin/ruby

size = 2	# default

# get arguments and sanity/error checking on parameters
require 'getoptlong'

opts = GetoptLong.new( [ "--size", "-s", GetoptLong::OPTIONAL_ARGUMENT
] )
opts.each do |opt, arg|
if '--size' == opt
if arg.to_i.to_s != arg
puts 'Error: size param is not a number'
exit
end
size = arg.to_i
end
end

if 1 != ARGV.length
puts 'Usage: lcd.rb [-s <size>] <number>'
exit
end

value = ARGV[0].dup
if value.to_i.to_s != value
puts 'Error: argument is not a number'
exit
end


# bit patterns of which segments are off/on for each digit
bits = {
'0' => 0b01110111,
'1' => 0b00100100,
'2' => 0b01011101,
'3' => 0b01101101,
'4' => 0b00101110,
'5' => 0b01101011,
'6' => 0b01111011,
'7' => 0b00100101,
'8' => 0b01111111,
'9' => 0b01101111
}

# our lovely constant strings for off/on bars
HBar = [ ' ', '-' ].collect { |c| ' ' + c * size + ' ' }
LBar = [ ' ', '|' ]
RBar = [ ' ', '|' ].collect { |c| ' ' * size + c }


# turn each digit into its 7seg bit pattern
digits = value.split(//).collect { |o| bits[o] }

# for each segment, collect an array of 0 and 1 for all digits
seg = []
(0...7).each do |s|
seg[s] = digits.collect { |b| ((b >> s) & 0x01) }
end

# turn each horizontal segment into an array of horizontal bars
[0, 3, 6].each do |i|
seg[i].collect! { |x| HBar[x] }
end

# turn each vertical segment into an array of vertical bars
[ [1, 2], [4, 5] ].each do |t|
seg[ t[0] ].collect! { |x| LBar[x] }		# left verticals
seg[ t[1] ].collect! { |x| RBar[x] }		# right verticals (incl
center space)

# merge left and right bars into left, combining each string
pair
seg[ t[0] ] = seg[ t[0] ].zip(seg[ t[1] ]).collect { |s| s[0] +
s[1] }
end

# output!
puts seg[0].join(' ')
size.times do
puts seg[1].join(' ')
end
puts seg[3].join(' ')
size.times do
        puts seg[4].join(' ')
end
puts seg[6].join(' ')
