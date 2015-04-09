class Integer
 def inspect
   x = (self % 3 == 0 ? "Fizz" : "")
   x << ( self % 5 == 0 ? "Buzz" : "" )
   x.empty? ? self : x
 end
end

(1..100).each {|x| p x}
