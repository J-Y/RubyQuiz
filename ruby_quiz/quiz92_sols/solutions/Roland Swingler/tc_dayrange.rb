require 'dayrange'
require 'test/unit'

class TestDays < Test::Unit::TestCase
 def test_all
   d = DayRange.new(1,2,3,4,5,6,7)
   assert_equal("Mon-Sun", d.to_s)
 end

 def test_end
   d = DayRange.new(1,2,3,4,5,6)
   assert_equal("Mon-Sat", d.to_s)
 end

 def test_start
   d = DayRange.new(2,3,4,5,6,7)
   assert_equal("Tue-Sun", d.to_s)
 end

 def test_alternate
   d = DayRange.new(1,3,4,6,7)
   assert_equal("Mon, Wed, Thu, Sat, Sun", d.to_s)
 end

 def test_no_wrap
   d = DayRange.new(1,2,3,6,7)
   assert_equal("Mon-Wed, Sat, Sun", d.to_s)
 end

 def test_order_unimportant
   d = DayRange.new(4,1,5,6,3)
   assert_equal("Mon, Wed-Sat", d.to_s)
 end

 def test_single
   d = DayRange.new(7)
   assert_equal("Sun", d.to_s)
 end

 def test_two
   d = DayRange.new(7,1)
   assert_equal("Mon, Sun", d.to_s)
 end

 def test_two_names
   d = DayRange.new("Monday", "Sun")
   assert_equal("Mon, Sun", d.to_s)
 end

 def test_error_raised
   assert_raise(ArgumentError){
     d = DayRange.new(1, 8)
   }
 end

 def test_week_start_friday
   d = DayRange.new(5,6,7,1)
   d.start = "Fri"
   assert_equal("Fri-Mon", d.to_s)
 end

 def test_week_start_can_be_changed
   d = DayRange.new(5,6,7,1)
   assert_equal "Mon", d.start
   d.start = 5
   assert_equal("Fri-Mon", d.to_s)
   d.start = "Sat"
   assert_equal("Sat-Mon, Fri", d.to_s)
   d.start = "Monday"
   assert_equal("Mon, Fri-Sun", d.to_s)
 end
end
