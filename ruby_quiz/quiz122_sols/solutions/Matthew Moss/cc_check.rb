class Integer
	def digitSum
		self.to_s.split(//).inject(0) { |s, d| s + d.to_i }
	end
end

class CreditCard

	TYPE_MATCH = {
		:visa       =>  /^4/,
		:discover   =>  /^6011/,
		:amex       =>  /^3(4|7)/,
		:mastercard =>  /^5[1-5]/
	}

	SIZE_MATCH = {
		:visa       =>  [13, 16],
		:discover   =>  [16],
		:amex       =>  [15],
		:mastercard =>  [16]
	}

	CARD_NAME = {
		:visa 		=>  "Visa",
		:discover   =>  "Discover",
		:amex       =>  "American Express",
		:mastercard =>  "MasterCard",
		:unknown    =>  "unknown",
		nil         =>  "invalid"
	}

	def initialize(cc)
		@cc = cc.delete(" ")
	end

	def valid?
		self.type && (self._luhn % 10).zero?
	end

	def type
		TYPE_MATCH.each do |k, v|
			if @cc =~ v
				if SIZE_MATCH[k].find { |n| @cc.size == n }
					return k
				else
					return nil
				end
			end
		end
		:unknown
	end

	def name
		CARD_NAME[self.type]
	end

	def to_s
		@cc
	end

	def _luhn
		sum = 0
		cc = @cc.split(//)
		until cc.empty?
			a, b = cc.pop.to_i, cc.pop.to_i
			sum += a + (2 * b).digitSum
		end
		sum
	end
end

cc = CreditCard.new(ARGV.join)
if !cc.valid?
	puts "Card #{cc} is invalid."
elsif cc.type != :unknown
	puts "Card #{cc} is a valid #{cc.name}."
else
	puts "Card #{cc} is unknown type, may be valid."
end
