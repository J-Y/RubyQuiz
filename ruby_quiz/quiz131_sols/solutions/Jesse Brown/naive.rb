#!/usr/bin/env ruby
#
# Jesse Brown
#
# This solution falls to a horrible geometric series
# Its simple to write and effetive for (very) small sets.
# O(2^n)
#
# Limitations (other than the runtime):
# This script would get you fired, dont use it ;)
# The overuse of global variable could have been 
# worked out of the design with little effort.
#

ARY_SZ = 10

# The recursive workhorse
def max_sub(sum, left, right)
   return if left > right
   $sum, $left, $right = sum, left, right if sum > $sum
   max_sub(sum - $ary[left], left + 1, right)   
   max_sub(sum - $ary[right], left, right - 1)
end

# Generate random N-element array ranged (-N, N)
$ary = (-ARY_SZ..ARY_SZ).to_a.sort_by {rand}[0..ARY_SZ] 

$left = 0
$right = ARY_SZ
$sum = eval $ary.join('+') # needed for an all negative array

max_sub((eval $ary.join('+')), 0, ARY_SZ)

puts "Array     : [ " + $ary.join(' , ') + " ]"
puts "Sum       : " + $sum.to_s
puts "Sub Array : [ " + $ary[$left..$right].join(' , ') + " ]\n\n"
   