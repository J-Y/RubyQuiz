1.upto(100) {|i| x = "Fizz" if i%3 == 0; x = (x || "") + "Buzz" if i%5 == 0; print x||i,' '}