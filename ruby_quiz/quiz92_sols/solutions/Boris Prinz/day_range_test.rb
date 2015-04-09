require 'day_range'
require 'test/unit'

class DayRangeTest < Test::Unit::TestCase
  def test_new
    dr = DayRange.new(1, 5)
    assert_equal WeekDay.new(1), dr.begin
    assert_equal WeekDay.new(5), dr.end
  end

  def test_argument_error
    assert_raise(ArgumentError) { DayRange.new(1, 8) }
    assert_raise(ArgumentError) { DayRange.new(0, 3) }
    assert_raise(ArgumentError) { DayRange.new(-1, 3) }

    assert_raise(ArgumentError) { DayRangeArray.new(1, 8) }
    assert_raise(ArgumentError) { DayRangeArray.new('funday') }
  end

  def test_to_s
    assert_equal 'Fri-Sun',  DayRange.new(5, 7).to_s
    assert_equal 'Mon-Fri',  DayRange.new(1, 5).to_s
    assert_equal 'Wed',      DayRange.new(3, 3).to_s
    assert_equal 'Mon, Tue', DayRange.new(1, 2).to_s
  end

  def test_day_range_list
    exp = {
      [1,2,3,4,5,6,7] => 'Mon-Sun',
      [1,2,3,6,7]     => 'Mon-Wed, Sat, Sun',
      [1,3,4,5,6]     => 'Mon, Wed-Sat',
      [2,3,4,6,7]     => 'Tue-Thu, Sat, Sun',
      [1,3,4,6,7]     => 'Mon, Wed, Thu, Sat, Sun',
      [7]             => 'Sun',
      [1,7]           => 'Mon, Sun',
      [7,6,7,4,3]     => 'Wed, Thu, Sat, Sun',
      []              => '',
      ['mon', 'Tuesday', 'WED', 5, 'saturday', 'sUnDaY'] => 'Mon-Wed, Fri-Sun'
    }

    exp.each do |list, string|
      assert_equal string,  DayRangeArray.new(*list).to_s
    end
  end
end
