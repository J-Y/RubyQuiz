#!/usr/local/bin/ruby

$last = 100

(1..$last).each do |num|
  if (num % 3) == 0 || (num % 5) == 0
    print "Fizz" if (num % 3) == 0
    print "Buzz" if (num % 5) == 0
    puts
  else
    puts num
  end
end
