#!/usr/local/bin/ruby
# Creator: Harlan Stern
# Created: June 4, 2007
# Why:     Ruby Quiz #126 Submission
 
def multiple?( d, m )
  # Test digit d for multiple of m
  d % m == 0 ? true : false
end

if __FILE__==$0:
  # Count from 1 to 100, print 'Fizz' for multiples of 3, 'Buzz' for multiples of 5, 
  # and 'FizzBuzz' for multiples of 3 and 5
  (1..100).each do |n|
    s = ''
    s << 'Fizz' if multiple?( n, 3 )
    s << 'Buzz' if multiple?( n, 5 )
    puts s.size > 0 ? s : n
  end
  
end