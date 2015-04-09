#### The one I like:

1.upto(100) do |i|
  a, b = i%3, i%5

  print "fizz" if a==0
  print "buzz" if b==0
  print i if a!=0 && b!=0
  puts
end
