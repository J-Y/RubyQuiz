#!/usr/bin/env ruby
#

require 'days'
require 'test/unit'

class DaysTester < Test::Unit::TestCase

	TestException = Class.new Exception

	def setup
		@numeric_conversions = [
			["", []],
			["Mon-Sun", [*1..7] ],
			["Mon,Sun", 1, 7 ],
			["Mon,Tue", 1, 2 ],
			["Mon,Tue,Thu", 1, 2, 4 ],	
			["Mon-Thu,Sat,Sun", 1, 2, 3, 4, 6, 7 ],
			["Mon,Fri-Sun", 1, 5, 6, 7 ],
			["Mon-Wed,Fri-Sun", 1, 2, 3, 5, 6, 7 ],
			["Wed,Thu,Sat,Sun", 3, 4, 6, 7 ],
			["Wed-Fri,Sun", 3, 4, 5, 7 ],
			["Mon,Wed-Sat", [1, [*3..6]]]
		]

		@alpha_conversions = [
			["Mon-Sun", "Mon", "Tu", "Sunday", "Wed", "Sat", "Fri", "Monday", "Thu"],
			["Mon,Tue", "Mo", "Tuesday" ],
			["Mon,Fri-Sun", "Mon", "Su", "Friday", "Sat"],
			["Mon,Wed,Thu,Sat,Sun", 3, 4, "Mo", "saturday", 7 ],
			["Tue-Fri,Sun",         7, "tue", 3, "Th", 5 ],
			["Mon,Tue,Thu,Fri,Sun", "Su", "Fr", 1, 2, 4 ],
			["Mon-Thu,Sat", "Mo-Wed", "sat", 4 ],
			["Tue-Sun", "Tuesday-Fri,We-Sat,Sun" ]
		]

		a = ArgumentError
		@errors = [
			[a, 0],
			[a, 1, 8],
			[a, 2, "Cru"]
		]

		@typo_correction = [
			["Sun", "Sux"],
			["Sun", "sun"],	
			["Tue", "Tuh"] ### This shows that it is a *problematic* feature
		]
		
		@parsing = [
			["Mon-Fri,Sun", "Mon-Fri", 7],
			["Mon-Wed,Fri-Sun", [*1..3], "Fri-Sun"],
			["Mon,Tue,Fri-Sun", "Fri,Sat,Sun,Mon-Tue"], # again very forgiving, so am I ;)
			["Tue-Fri,Sun",  "Sun,Tue-Fri"],
			["Mon-Sun", "Mon-Fri,Sun", "Sa"]
		]

		## Put the features you want to test in the instance variable below
		@testcases = [ @numeric_conversions, @alpha_conversions, @errors, 
				@typo_correction, @parsing ]
	end
	def test_all
		@testcases.each do
			| testcase |
			testcase.each do
				|conv|
				expected = conv.shift
				args = conv.flatten
				case expected
					when String
						assert_equal expected, Days.new( *args ).to_s, 
							"from testcase args: \"#{args.join(",")}\""
					when Class
						raise TestException, 
				"Illegal setup of testcase #{expected.inspect} not allowed" unless
						expected < Exception
						assert_raises expected do
								Days.new( *args ).to_s
						end
					when nil
						assert_nothing_raised do
								Days.new( *args ).to_s
						end
					else
						raise TestException, "Illegal setup of testcase #{expected.inspect} not allowed"
				end # case expected
			end
		end
	end # test


	#
	# Uncomment the following tests if you want a special feature
	#
	
end
