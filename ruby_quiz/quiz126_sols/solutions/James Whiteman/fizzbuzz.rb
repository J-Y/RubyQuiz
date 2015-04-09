# by James Whiteman

class Fixnum

 alias_method :old_to_s, :to_s

 def to_s
   if (self % 3).zero? && (self % 5).zero?
     return "FizzBuzz"
   elsif (self % 3).zero?
     return "Fizz"
   elsif (self % 5).zero?
     return "Buzz"
   else
     old_to_s
   end
 end
end

(1..100).each { |x| puts x }
