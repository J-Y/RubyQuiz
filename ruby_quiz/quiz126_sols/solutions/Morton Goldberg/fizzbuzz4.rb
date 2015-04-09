# ... or even with the ternary operator.
(1..100).each do |n|
   puts(
      n % 15 == 0 ? 'FizzBuzz' :
      n % 5 == 0  ? 'Buzz' :
      n % 3 == 0  ? 'Fizz' : n
   )
end
