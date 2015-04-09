#!/usr/bin/env ruby -w

class CreditCard
	attr_reader :number, :type, :validity
	def initialize(cardnumber)
		@number = cardnumber.gsub(/\s/,'')
		@type = case @number
		when /^3[47]\d{13}$/ then "AMEX"
		when /^6011\d{12}$/ then "Discover"
		when /^5[12345]\d{14}$/ then "Mastercard"
		when /^4\d{12}$/ then "VISA"
		when /^4\d{15}$/ then "VISA"
		else "Unknown"
		end
		sum = 0
		digits = @number.to_s.split('').reverse.map {|i| i.to_i}
		digits.each_index {|i| i%2==0 ? sum+=add_digits(digits[i]) : sum+=add_digits(digits[i]*2)}
		@validity = sum%10 == 0 ? "Valid" : "Invalid"
	end
	def add_digits(n)
		return n.to_s.split('').inject(0) {|sum, i| sum += i.to_i}
	end
end #CreditCard

c = CreditCard.new(ARGV.join)
puts "#{c.number}: #{c.type}\t#{c.validity}"
