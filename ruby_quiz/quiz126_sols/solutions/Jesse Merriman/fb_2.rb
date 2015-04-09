#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_2.rb

Fizz = 3
Buzz = 5

arr = Array.new(100) do |i|
  x = i + 1
  if (x % Fizz).zero?
    if (x % Buzz).zero? then 'FizzBuzz'
    else                     'Fizz' end
  elsif (x % Buzz).zero? then 'Buzz'
  else                        x end
end

arr.each { |e| puts e }
