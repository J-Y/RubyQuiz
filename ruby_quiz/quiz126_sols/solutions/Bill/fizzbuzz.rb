# First attempt

(1..100).each { |n|
	if n % 3 == 0 then
		print "Fizz"
	end
	if n % 5 == 0 then
		print "Buzz"
	end
	if (n%3 != 0) and (n%5 != 0) then
		print n
	end
	print "\n"
}
