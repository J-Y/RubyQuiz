# Of course, could do it with if-elsif-else ...
(1..100).each do |n|
   puts(
      if n % 15 == 0
         'FizzBuzz'
      elsif n % 5 == 0
         'Buzz'
      elsif n % 3 == 0
         'Fizz'
      else n
      end
   )
end
