# Simple, obvious (to me) way to do it.
(1..100).each do |n|
   case
   when n % 15 == 0 : puts 'FizzBuzz'
   when n % 5 == 0  : puts 'Buzz'
   when n % 3 == 0  : puts 'Fizz'
   else puts n
   end
end
