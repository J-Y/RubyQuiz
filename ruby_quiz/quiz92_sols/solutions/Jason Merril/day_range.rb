require 'test/unit'

class DateRange
	
	DAY_NUMBERS = {	
					1 => 'Mon',
					2 => 'Tue',
					3 => 'Wed',
					4 => 'Thu',
					5 => 'Fri',
					6 => 'Sat',
					7 => 'Sun'
				}
	
	# Creates a new DateRange from a list of representations of days of the week
	def initialize(*args)
		
		# Convert the arguments to an array of day numbers
		arr = args.collect {|rep| DateRange.day_num(rep)}
		arr.uniq!
		arr.sort!
		
		@string = DateRange.build_string(arr)
		
	end
	
	# Given a sorted array of day numbers, build the string representation
	def self.build_string(arr)
		result = ''
		
		while i = arr.shift
			
			# Add the day name to the string
			result << "#{DAY_NUMBERS[i]}"
			
			# If there is a run of 3 or more consecutive days, add a '-' character,
			# and then put the last day of the run after it
			if arr[1] == i + 2
				result << '-'
				i = arr.shift while arr.first == i + 1
				result << "#{DAY_NUMBERS[i]}"
			end
			
			# Unless this is the last day
			result << ', ' if arr.first
		end
		
		result
	end
	
	# Returns the number representation of a day of the week specified by number,
	# name, or abbreviation
	#
	# DateRange.day_num(2) => 2
	# DateRange.day_num('Fri') => 5
	# DateRange.day_num('saturday') => 6
	def self.day_num(rep)
		if (1..7).include?(rep.to_i)
			rep.to_i
		else
			result = DAY_NUMBERS.index(rep[0,3].capitalize)
			raise ArgumentError unless result
			result
		end
	end
	
	def to_s
		@string
	end
	
end

class DateRangeTest < Test::Unit::TestCase
	
	def test_init
		assert_equal('Mon-Sun', DateRange.new(1,2,3,4,5,6,7).to_s)
		assert_equal('Mon-Wed, Sat, Sun', DateRange.new(1,2,3,6,7).to_s)
		assert_equal('Mon, Wed-Sat', DateRange.new(1,3,4,5,6).to_s)
		assert_equal('Tue-Thu, Sat, Sun', DateRange.new(2,3,4,6,7).to_s)
		assert_equal('Mon, Wed, Thu, Sat, Sun', DateRange.new(1,3,4,6,7).to_s)
		assert_equal('Sun', DateRange.new(7).to_s)
		assert_equal('Mon, Sun', DateRange.new(1,7).to_s)
		assert_equal('Mon-Fri', DateRange.new(*%w(Wednesday Monday Tuesday Thursday Friday Monday)).to_s)
		assert_raise(ArgumentError) {DateRange.new(1,8)}
	end

end
