require 'mathn'

class Prime
	def last
		@primes.last
	end
end

class String
	def to_godel(primes=Prime.new)
		return 1 if size.zero?
		return (primes.next ** (1 + self[0])) * slice(1,size).to_godel(primes)
	end
	def self.from_godel(num,primes=Prime.new)
		return "" unless num > 1
		multiplicity = factor_multiplicity(primes.next,num)
		(multiplicity-1).chr + from_godel(num / (primes.last ** multiplicity), primes)
	end
	private
	def self.factor_multiplicity(factor,num)
		1.upto(num) {|x| return x - 1 unless num.modulo(factor**x).zero?}
	end
end

puts "Test encoding: "+"Ruby\n".to_godel.to_s+"\n"
puts "Test decoding: "+String.from_godel("Ruby\n".to_godel)+"\n"
