#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_0.rb

Fizz = 3
Buzz = 5
FizzBuzz = Fizz * Buzz

(1..100).each do |x|
  if    (x % FizzBuzz).zero? then puts 'FizzBuzz'
  elsif (x % Fizz).zero?     then puts 'Fizz'
  elsif (x % Buzz).zero?     then puts 'Buzz'
  else                            puts x
  end
end
