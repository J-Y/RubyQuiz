a = (1..100).inject([]){|hash, x| hash[x-1] = x unless x%3
==0 || x%5==0 || x%15==0 ; hash[x-1] = 'Fizz' if x%3==0 ; hash[x-1] = 'Buzz'
if x%5==0 ; hash[x-1] = 'FizzBuzz' if x%15==0 ; hash}

a.each{|x| p x}