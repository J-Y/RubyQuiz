for i in 1..100
	mod3 = (i % 3 == 0)
	mod5 = (i % 5 == 0)
	
	print "Fizz" if mod3
	print "Buzz" if mod5
	print i if !mod3 && !mod5

	puts ""
end