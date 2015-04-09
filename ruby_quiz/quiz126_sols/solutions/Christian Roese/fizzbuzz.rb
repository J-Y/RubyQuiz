#!/usr/bin/ruby -w
###########################
# Filename: fizzbuzz.rb
# Author: Christian Roese
# Date: 2007-06-01
###########################
# Ruby Quiz - FizzBuzz (#126)
# This program will print out the numbers from 1 to 100,
# replacing multiples of 3 with "Fizz", the multiples of
# 5 with "Buzz", and the multiples of 3 and 5 with "FizzBuzz"

# I love me some constants!
START, STOP, FIZZ, BUZZ, BOTH = 1, 100, 3, 5, 15

START.upto(STOP) do |n|
 result = if (n % BOTH == 0) then "FizzBuzz"
             elsif (n % FIZZ == 0) then "Fizz"
             elsif (n % BUZZ == 0) then "Buzz"
             else n
             end
 puts result
end
