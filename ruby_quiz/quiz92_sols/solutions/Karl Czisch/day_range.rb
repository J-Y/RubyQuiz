class DayRange
	@@days = {'Mon' => 1, 'Tue' => 2, 'Wed' => 3, 'Thu' => 4, 'Fri' => 5, 'Sat' => 6, 'Sun' => 7}
	
	def initialize(*input)
		@numbers = Array.new
		
		input.each do |arg|
			num = 0
			if arg.kind_of?(Numeric)
				num = arg
			elsif arg.kind_of?(String)
				num = @@days[arg[0..2]]
			end
			raise ArgumentError, "Wrong parameters" if num == nil or num < 1 or num > 7
			@numbers << num
		end
	end

	def getNextRange
		left = right = nil
		@numbers.sort.each do |num|
			if left == nil
				left = right = num
			elsif num - right <= 1
				right = num
			else
				yield left, right
				left = right = num
			end
		end
		yield left, right if left
	end
	
	def to_s
		days_inv = @@days.invert
		s = ""
		getNextRange do |from, to|
			s << ', ' unless s.empty?
			s << days_inv[from]
			if to > from
				s << (to - from > 1 ? "-" : ", ")
				s << days_inv[to]
			end
		end
		s
	end
end

puts DayRange.new(1,2,3,4,5,6,7)
puts DayRange.new(1,2,3,6,7)
puts DayRange.new(1,3,4,5,6)
puts DayRange.new(2,3,4,6,7)
puts DayRange.new(1,3,4,6,7)
puts DayRange.new(7)
puts DayRange.new(1,7)
puts DayRange.new(1,8)
