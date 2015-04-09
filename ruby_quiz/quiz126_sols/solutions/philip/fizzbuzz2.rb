c=100
def square_coop x
	a3=(x % 3 == 0) ? 1 : 0
	a5=(x % 5 == 0) ? 2 : 0
	
	case a3+a5
		when 0 : x
		when 1 : "Fizz"
		when 2 : "Buzz"
		when 3 : "FizzBuzz"
	end
end
	
(1..c).each {|x| 
	puts square_coop(x) }
