#! /usr/bin/env ruby

def sum_dig_sq(ival)
 sum = 0
 while ival > 0 do
   ival,dig = ival.divmod(10)
   sum += (dig * dig)
 end
 return sum
end

def happy?(ival)
# sad #s from http://mathworld.wolfram.com/HappyNumber.html
sad = [0, 4, 16, 20, 37, 42, 58, 89, 145]
rank = 0
while true do
 return -1 if sad.include?(ival) # check sad 1st - ~87% are sad
 ival = sum_dig_sq(ival)
 return rank if ival == 1
 rank += 1
end
end

if ARGV[0].to_i <= 0
 warn "usage: #{$0} <number>\n  number must be > 0"
 exit
end

processed = []
happiest = []
(0..ARGV[0].to_i).each {|cur_num|
 base = cur_num.to_s.split('').sort.join.to_i
 processed[base] = happy?(cur_num) unless processed[base]
 rank = processed[base]
 next if rank  < 0

 puts "#{cur_num} is happy - rank #{rank}"
 happiest[rank] = cur_num unless happiest[rank]
}

happiest.each_with_index do |val, ndx|
 puts "Happiest number of rank #{ndx} is #{val}"
end
