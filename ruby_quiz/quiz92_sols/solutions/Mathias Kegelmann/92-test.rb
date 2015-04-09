require 'test/unit'
require '92-DateRange'

class DateRangeTest < Test::Unit::TestCase

  def test_runs
    assert_equal [], [].runs
    assert_equal [[1]], [1].runs
    assert_equal [[1,2]], [1,2].runs
    assert_equal [[1],[3]], [1,3].runs
    assert_equal [[1,2,3],[5],[3,4],[2]], [1,2,3,5,3,4,2].runs
  end

  def test_day_to_i
    assert_equal 1, DateRange.day_to_i(1)
    assert_equal 2, DateRange.day_to_i("Tuesday")
    assert_equal 3, DateRange.day_to_i("Wed")
    assert_equal 4, DateRange.day_to_i(4)
    assert_equal 5, DateRange.day_to_i("Friday")
    assert_equal 6, DateRange.day_to_i("Sat")
    assert_equal 7, DateRange.day_to_i("Sunday")
    assert_raise(ArgumentError) { DateRange.day_to_i("Hello") }
    assert_raise(ArgumentError) { DateRange.day_to_i(0) }
    assert_raise(ArgumentError) { DateRange.day_to_i(8) }
  end

  def test_i_to_s
    assert_equal "Mon", DateRange.i_to_s(1)
    assert_equal "Tue", DateRange.i_to_s(2)
    assert_equal "Wed", DateRange.i_to_s(3)
    assert_equal "Thu", DateRange.i_to_s(4)
    assert_equal "Fri", DateRange.i_to_s(5)
    assert_equal "Sat", DateRange.i_to_s(6)
    assert_equal "Sun", DateRange.i_to_s(7)
    assert_raise(ArgumentError) { DateRange.i_to_s(0) }
    assert_raise(ArgumentError) { DateRange.i_to_s(8) }
  end

  def test_date_range 
    assert_equal "", DateRange.new().to_s
    assert_equal "Mon", DateRange.new(1).to_s
    assert_equal "Mon, Tue", DateRange.new(1,2).to_s
  end

  def test_quiz_cases
    assert_equal "Mon-Sun", DateRange.new(1,2,3,4,5,6,7).to_s
    assert_equal "Mon-Wed, Sat, Sun", DateRange.new(1,2,3,6,7).to_s
    assert_equal "Mon, Wed-Sat", DateRange.new(1,3,4,5,6).to_s
    assert_equal "Tue-Thu, Sat, Sun", DateRange.new(2,3,4,6,7).to_s
    assert_equal "Mon, Wed, Thu, Sat, Sun", DateRange.new(1,3,4,6,7).to_s
    assert_equal "Sun", DateRange.new(7).to_s
    assert_equal "Mon, Sun", DateRange.new(1,7).to_s
    assert_raise(ArgumentError) { DateRange.new(1,8).to_s }
  end

end
