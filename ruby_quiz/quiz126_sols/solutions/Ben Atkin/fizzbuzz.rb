(1..100).each do |i|
 print i.to_s + ' '
 print 'Fizz' if i % 3 == 0
 print 'Buzz' if i % 5 == 0
 puts
end
