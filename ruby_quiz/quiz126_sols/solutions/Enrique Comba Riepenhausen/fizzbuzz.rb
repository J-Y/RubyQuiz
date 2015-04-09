1.upto(100) do |number|
  print "Fizz" if number % 3 == 0
  print "Buzz" if number % 5 == 0
  print number if number % 3 != 0 && number % 5 != 0
  puts ""
end
