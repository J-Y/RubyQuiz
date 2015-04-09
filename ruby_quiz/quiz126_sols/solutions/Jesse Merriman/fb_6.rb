#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_6.rb

FB = lambda { |mod, str| lambda { |x| (x % mod).zero? ? str : x } }
Fizz     = FB[3,  'Fizz']
Buzz     = FB[5,  'Buzz']
FizzBuzz = FB[15, 'FizzBuzz']

# Note that this wouldn't work if the numbers to_s'd got longer than their
# fizz-buzzed strings.
(1..100).each do |x|
  puts([Fizz[x], Buzz[x], FizzBuzz[x]].max do |a,b|
    a.to_s.length <=> b.to_s.length
  end)
end
