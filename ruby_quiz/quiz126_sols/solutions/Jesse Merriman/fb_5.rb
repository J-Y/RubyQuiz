#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_5.rb

class Integer
  def fizzbuzz arr, str
    arr.each_with_index do |x, i|
      arr[i] = ((i+1) % self).zero? ? str : x
    end
  end
end

arr = (1..100).to_a
3.fizzbuzz arr, 'Fizz'
5.fizzbuzz arr, 'Buzz'
15.fizzbuzz arr, 'FizzBuzz' # Must be last.

arr.each { |x| puts x }
