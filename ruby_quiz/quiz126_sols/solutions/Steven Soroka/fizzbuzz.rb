#!/usr/bin/ruby
class Fixnum
  alias_method :old_to_s, :to_s
  def to_s
    s = "Fizz" if self % 3 == 0
    s = (s || "") + "Buzz" if self % 5 == 0
    "#{s || old_to_s}"
  end
end

(1..100).each {|i| puts i }
