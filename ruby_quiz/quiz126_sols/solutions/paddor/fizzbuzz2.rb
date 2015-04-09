(1..100).each { |n| puts n % 3 == 0 ? n % 5 == 0 ? :FizzBuzz : :Fizz :
n % 5 == 0 ? :Buzz : n }