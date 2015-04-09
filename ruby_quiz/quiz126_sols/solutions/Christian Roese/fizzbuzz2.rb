#!/usr/bin/ruby -w
###########################
# Filename: fizzbuzz2.rb
# Author: Christian Roese
# Date: 2007-06-01
###########################

# change the way Fixnum's spit out their value
class Fixnum
 FIZZ, BUZZ, BOTH = 3, 5, 15
 def inspect
   result = if (self % BOTH == 0) then "FizzBuzz"
            elsif (self % FIZZ == 0) then "Fizz"
            elsif (self % BUZZ == 0) then "Buzz"
            else self
            end
 end
end

# main loop
(1..100).each { |x| p x }
