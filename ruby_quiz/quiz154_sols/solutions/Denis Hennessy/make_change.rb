#!/usr/bin/env ruby

def greatest_common_divisor(a, b)
 return a if b == 0
 greatest_common_divisor(b, a % b)
end

def least_common_multiple(a, b)
 return 0 if a == 0 or b == 0
 (a * b) / greatest_common_divisor(a, b)
end

def make_change(value, coins=[])
 return [] if value == 0
 return nil if coins.empty?

 puts "make_change #{value}, #{coins.inspect}" if $VERBOSE

 best = nil
 coins.each_with_index do |c, i|
   lcm = coins[0,i].inject(0) { |memo, val| lcm = least_common_multiple(c, val); lcm > memo && lcm <= value ? lcm : memo}
   start = lcm == 0 ? 0 : (value - (value % lcm)) / c
   lcm = coins[i+1,coins.size].inject(c) { |memo, val| least_common_multiple(memo, val)}
   if lcm != 0
     try = (value - (value % lcm)) / c
     start = try if try > start && try <= value
   end
   max = value / c
   others = coins.reject {|v| v == c}
   start = max if others.empty?
   start.upto(max) do |n|
     remaining = value - n * c
     change = make_change(remaining, others)
     next if change == nil
     try = [c] * n + change
     best = try if best.nil? or try.size < best.size
   end
 end
 best.sort!.reverse! if best
 best
end

if $0 == __FILE__
 if ARGV.size == 0
   puts "Usage: #{File.basename($PROGRAM_NAME)} <value> <coin> <coin>..."
   exit
 end
 value = ARGV.shift.to_i
 coins = ARGV.collect {|c| c.to_i}
 coins.sort!.reverse!

 change = make_change value, coins
 if change
   puts change.inspect
 else
   puts "It's not possible to make #{value} with coins of value #{coins.inspect}"
 end
end
