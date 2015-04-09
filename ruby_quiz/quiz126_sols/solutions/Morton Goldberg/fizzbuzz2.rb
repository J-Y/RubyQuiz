# Not quite so obvious, but a little DRYer:
(1..100).each do |n|
   puts  case
         when n % 15 == 0 : 'FizzBuzz'
         when n % 5 == 0  : 'Buzz'
         when n % 3 == 0  : 'Fizz'
         else n
         end
end
