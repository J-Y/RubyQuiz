#!/usr/bin/env ruby
#
# Jesse Brown
#
# By using a dynamic programming approach the previous
# geometric series can be reduced to an arithmetic series
# O(n^2)
#
# Limitations:
# Since there is no look-ahead feature here, zero-padded
# arrays will leave off the left zeros.
# ie. [0,0,4,0,0] produces [4,0,0]
# It is the correct sum, but not the maximum sized array

ARY_SZ = 5

def max_sub(ary)
   
   start = stop = 0
   max = ary[0]
   sums = []
   
   # First calculate the sum for each sub array starting from index 0
   sums << ary[0]
   (1..ARY_SZ).each do |i| 
      sums << sums[i-1] + ary[i] 
      max, stop = sums[-1], i if sums[-1] >= max
   end
   
   # now simply shift, loop, and adjust values and max as we go
   (0..(ARY_SZ - 1)).each do |i|
      ((i + 1)..ARY_SZ).each do |s|
         max, start, stop = sums[s], i + 1, s if (sums[s] -= sums[i]) >= max
      end
   end   
   return ary[start..stop]
end

# Generate random N-element array ranged (-N, N)
a = (-ARY_SZ..ARY_SZ).to_a.sort_by {rand}[0..ARY_SZ] 
sub = max_sub a
puts "Array     : [ " + a.join(' , ') + " ]"
puts "Sum       : #{eval sub.join('+')}"
puts "Sub Array : [ " + sub.join(' , ') + " ]\n\n"
