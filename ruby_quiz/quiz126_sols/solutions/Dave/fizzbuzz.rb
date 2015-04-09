#Quick first attempt

1.upto(100) {|i| puts(i%15==0 ? 'FizzBuzz' : i%5==0 ? 'Buzz' : i%3==0 ? 'Fizz' : i)}