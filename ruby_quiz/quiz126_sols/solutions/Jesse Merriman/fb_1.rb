#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_1.rb

Fizz = 3
Buzz = 5

(1..100).each do |x|
  if (x % Fizz).zero?
    if (x % Buzz).zero? then puts 'FizzBuzz'
    else                     puts 'Fizz' end
  elsif (x % Buzz).zero? then puts 'Buzz'
  else                        puts x end
end
