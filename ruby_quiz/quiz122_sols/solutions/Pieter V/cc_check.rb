num = ARGV.join

def luhn(number)
	double = true
	luhn = 0
	number.scan(/./) do |digit|
		n = digit.to_i * (double ? 2 : 1)
		luhn += n % 10 + n / 10
		double = !double
	end
	(luhn % 10) == 0
end

def type(number)
	case number
		when /^34|37[0-9]{13}/ then "AMEX"
		when /^6011[0-9]{12}/ then "Discover"
		when /^5[1-5][0-9]{14}/ then "MasterCard"
		when /^4([0-9]{12}|[0-9]{15})/ then "Visa"
		else "Unknown"
	end
end

puts "Type:  %s" % type(num)
puts "Valid: %s" % (luhn(num) ? :true : :false)
