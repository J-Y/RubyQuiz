# Straightforward solution

(1..100).each do |n|
  print "Fizz" if 0 == n % 3
  print "Buzz" if 0 == n % 5
  print n if 0 != n % 3 and 0 != n % 5
  print "\n"
end
