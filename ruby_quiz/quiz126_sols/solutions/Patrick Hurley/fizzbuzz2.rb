module Enumerable
 def map_every(n)
   m = n - 1
   result = []

   self.each_with_index do |elem,i|
     if i % n == m
       result << yield(elem,i)
     else
       result << elem
     end
   end

   result
 end
end

result = *1..100
result = result.map_every(3)  { "Fizz" }
result = result.map_every(5)  { "Buzz" }
result = result.map_every(15) { "FizzBuzz" }
puts result
