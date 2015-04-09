#!/usr/bin/env ruby
# Ruby Quiz 126: FizzBuzz
# fb_3.rb

Fizz = 3
Buzz = 5
FizzBuzz = Fizz * Buzz

class Fixnum
  alias :old_to_s :to_s
  def to_s; (self % FizzBuzz).zero? ? 'FizzBuzz' :
            (self % Fizz).zero?     ? 'Fizz' :
            (self % Buzz).zero?     ? 'Buzz' :
                                      old_to_s
  end
end

# Peter Seebach's suggestion.
(1..100).each { |x| p x }
