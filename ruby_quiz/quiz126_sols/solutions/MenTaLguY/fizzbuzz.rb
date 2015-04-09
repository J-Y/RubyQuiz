for n in 1..100
  mult_3 = ( n % 3 ).zero?
  mult_5 = ( n % 5 ).zero?
  if mult_3 or mult_5
    print "Fizz" if mult_3
    print "Buzz" if mult_5
  else
    print n
  end
  puts
end
