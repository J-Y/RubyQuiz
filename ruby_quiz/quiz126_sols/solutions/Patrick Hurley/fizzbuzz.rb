(1..100).each do |i|
 case
 when i % 15 == 0
   puts "FizzBuzz"
 when i % 3 == 0
   puts "Fizz"
 when i % 5 == 0
   puts "Buzz"
 else
   puts i
 end
end
