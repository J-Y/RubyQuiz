#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_4.rb

Fizz = 3
Buzz = 5
FizzBuzz = Fizz * Buzz

class Integer
  def fizzbuzz
    if    (self % FizzBuzz).zero? then 'FizzBuzz'
    elsif (self % Fizz).zero?     then 'Fizz'
    elsif (self % Buzz).zero?     then 'Buzz'
    else                          to_s
    end
  end
end

(1..100).each { |x| puts x.fizzbuzz }
