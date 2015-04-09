module Enumerable
 def change(to, &blk)
   map{ |x| blk.call(x) ? to : x }
 end
end # module Enumerable

puts (1..100).change(:FizzBuzz){ |x| x%15 == 0 }.change(:Fizz){ |x|
x%3 == 0 rescue false}.change(:Buzz){ |x| x%5 == 0 rescue false }
