require 'day_range.rb'
require 'test/unit'

class TestDayRange < Test::Unit::TestCase

	EsperantoMap = {"Lundo" => 1, "Lun" => 1, "Mardo" => 2, "Mar" => 2, "Merkredo" => 3, "Mer" => 3, 
			"Jhaudo" => 4, "Jha" => 4, "Vendredo" => 5, "Ven" => 5, "Sabato" => 6, "Sab" => 6,
			"Dimancho" => 7, "Dim" => 7}

	EsperantoNames = ["Lun", "Mar", "Mer", "Jha", "Ven", "Sab","Dim"]

	GermanMap = { "Montag" => 1, "Mon" => 1, "Dienstag" => 2, "Die" => 2, "Mittwoch" => 3, "Mitt" => 3,
		      "Donnerstag" => 4, "Don" => 4, "Freitag" => 5, "Frei" => 5, "Samstag" => 6, "Sam" => 6,
		      "Sonntag" => 7, "Sonn" => 7 }
	GermanNames = ["Mon", "Die", "Mitt", "Don", "Frei", "Sam", "Sonn"]

	def test_equal_1
		dr1 =  DayRange.new(1,2,4,5)
		dr2 =  DayRange.new(1,2,4,5)
		dr3 = DayRange.new(2,5,4,1)
		assert_equal(dr1,dr2)
		assert_equal(dr1,dr3)
	end

	def test_weekstart_1
		dr1 = DayRange.new('Mon', 'Tuesday', 'Thursday', 'Friday', 'Sat', :week_start => 2)
		assert_equal("Tue, Thu-Sat, Mon",dr1.to_s)
	end

	def test_equal_2
		dr1 =  DayRange.new(1,2,4,5)
		dr2 = DayRange.new('Monday', 'Tuesday', 'Thursday', 'Friday')
		assert_equal(dr1,dr2)
	end

	def test_to_s_numbers
		dr =  DayRange.new(1,2,4,5)
		assert_equal("Mon-Tue, Thu-Fri",dr.to_s(:min_span => 2))
		assert_equal("Mon, Tue, Thu, Fri",dr.to_s)
		dr =  DayRange.new(1,2,3, 5,6)
		assert_equal("Mon-Wed, Fri-Sat",dr.to_s(:min_span => 2))
		assert_equal("Mon-Wed, Fri, Sat",dr.to_s)
	end

	def test_to_s_names
		dr = DayRange.new('Monday', 'Tuesday', 'Thursday', 'Friday')
		assert_equal("Mon, Tue, Thu, Fri",dr.to_s)
		assert_equal("Mon-Tue, Thu-Fri",dr.to_s(:min_span => 2))
	end

	def test_to_s_options
		dr = DayRange.new('Monday', 'Tuesday', 'Thursday', 'Friday')
		assert_equal("Lun, Mar, Jeu, Ven", dr.to_s(:language => :French))
		assert_equal("Lun-Mar, Jeu-Ven", dr.to_s(:language => :French, :min_span => 2))
		assert_equal("Mercury-Venus, Mars-Saturn", 
			     dr.to_s(:day_names => %w[Mercury Venus Earth Mars Saturn Jupiter Uranus],
				    :min_span => 2)
			    )

	        dr = DayRange.new(1, 2, 3, 6, 7)
		assert_equal("Mon-Wed, Sat, Sun", dr.to_s)
		assert_equal("Tue, Wed, Sat-Mon", dr.to_s(:week_start => 2))
		assert_equal("Wed, Sat-Tue",dr.to_s(:week_start => 3))
		assert_equal("Sat-Wed", dr.to_s(:week_start => 4))
		assert_equal("Sat-Wed", dr.to_s(:week_start => 5))
		assert_equal("Sat-Wed", dr.to_s(:week_start => 6))
		assert_equal("Sun-Wed, Sat", dr.to_s(:week_start => 7))
	end
	def test_translate_to_french
		dr =  DayRange.new(1,2,4,5)
		assert_equal("Lun, Mar, Jeu, Ven",dr.to_s(:language => 'French'))
		assert_equal("Lun-Mar, Jeu-Ven",dr.to_s(:language => 'French', :min_span => 2))
	end

	def test_new_french
		dr1F = DayRange.new(1,2,4,5, :language => 'French')
		dr1 =  DayRange.new(1,2,4,5)
		assert_equal(dr1, dr1F)
		assert_equal("Lun-Mar, Jeu-Ven",dr1F.to_s(:min_span => 2))
		assert_equal("Mon-Tue, Thu-Fri",dr1F.to_s(:language => 'English', :min_span => 2))
		assert_equal("Lun, Mar, Jeu, Ven",dr1F.to_s)
		assert_equal("Mon, Tue, Thu, Fri",dr1F.to_s(:language => 'English'))
	end

	def test_new_esperanto
		dr1Esp = DayRange.new(1,2,4,5, :day_map => EsperantoMap)
		dr1 =  DayRange.new(1,2,4,5)
		assert_equal(dr1, dr1Esp)
		assert_equal("Lun-Mar, Jha-Ven", dr1Esp.to_s(:min_span => 2))
	end

	def test_bad_days
		assert_raise(ArgumentError) {DayRange.new(1,2,8)}
		assert_raise(ArgumentError) {DayRange.new(1, :day_map => {'Mon' => 1, "Tue" => 9})}
	end

	def test_add_german
		DayRange.remove_language(:German)
		DayRange.add_language(:German, GermanMap, GermanNames)
		assert_equal("Die, Don, Sam, Sonn", DayRange.new(2,4,6,7, :language => 'German').to_s)
		assert_equal("Die, Don, Sam-Sonn", DayRange.new(2,4,6,7, 
								:language => 'German').to_s(:min_span => 2))
		
		DayRange.remove_language(:German)
		DayRange.add_language(:German, GermanMap)
		assert_equal("Die, Don, Sam, Sonn", DayRange.new(2,4,6,7, :language => 'German').to_s)
		assert_equal("Die, Don, Sam-Sonn", DayRange.new(2,4,6,7, 
								:language => 'German').to_s(:min_span => 2))
	end

	def test_each_name
		dr = DayRange.new(1,2, 5, 6)
		expected = ['Mon', 'Tue', 'Fri', 'Sat']
		dr.each_name { |name| assert_equal(expected.shift, name)}
		assert(expected.empty?, "Missing results #{expected.inspect}")
		expected = ['Doc', 'Grumpy', 'Bashful', 'Sleepy']
		dwarves = ['Doc', 'Grumpy', 'Happy', 'Sneezy','Bashful', 'Sleepy', 'Dopey']
		dr.each_name(:day_names => dwarves) { |name| assert_equal(expected.shift, name)}
		assert(expected.empty?, "Missing results #{expected.inspect}")
		expected = ['Lun', 'Mar', 'Ven', 'Sam']
		dr.each_name(:language => 'French') { |name| assert_equal(expected.shift, name)}
		assert(expected.empty?, "Missing results #{expected.inspect}")
	end
end
