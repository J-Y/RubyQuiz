class Integer; def factor? n; self % n == 0; end; end

puts (1..100).map { |i| i.factor?(15)&&"FizzBuzz" || i.factor?
(3)&&"Fizz" || i.factor?(5)&&"Buzz" || i }
