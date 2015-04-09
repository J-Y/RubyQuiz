# Second Attempt

(1..100).each { |n|
	case
		when (n%3 == 0) && (n%5 == 0) then
			puts "FizzBuzz"
		when (n%3 == 0) then
			puts "Fizz"
		when (n%5 == 0) then
			puts "Buzz"
		else
			puts n
	end
}
