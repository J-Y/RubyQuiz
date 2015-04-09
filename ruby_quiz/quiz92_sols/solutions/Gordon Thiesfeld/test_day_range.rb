require 'test/unit'
require 'lib/days.rb'

class TestArray < Test::Unit::TestCase
  def test_collapse_ranges
    assert_equal( [(1..4),6], [1,2,3,4,6].collapse_ranges)
  end

  def test_to_s
    assert_equal([1,2,3].to_s, '1, 2, 3')
  end
end

class TestRange < Test::Unit::TestCase
  def test_to_s
    assert_equal((1..3).to_s, '1-3')
  end
end

class TestDay < Test::Unit::TestCase
  def setup
    @day = Day.commercial(6)
    @next_day = Day.commercial('Sun')
  end

  def test_error
    assert_raise(ArgumentError){ Day.commercial('not') }
    assert_raise(ArgumentError){ Day.commercial(8) }
  end

  def test_succ
    assert_equal(@day.succ.cwday,7)
  end

  def test_spaceship
    assert(@day < @next_day)
  end

  def test_to_s
    assert_equal('Sat', @day.to_s)
  end
end

class TestDayRange< Test::Unit::TestCase
  def test_to_s 
     [
      [[1,2,3,4,5,6,7],'Mon-Sun'],
      [[1,2,3,6,7], "Mon-Wed, Sat, Sun"],
      [[1,3,4,5,6], "Mon, Wed-Sat"],
      [[2,3,4,6,7], "Tue-Thu, Sat, Sun"],
      [[1,3,4,6,7],  "Mon, Wed, Thu, Sat, Sun"],
      [[7], "Sun"],
      [[1,7], "Mon, Sun"] ,
      [['Tue','Wed','Thu','Fri'],"Tue-Fri"],
      [['Wednesday','Thursday','Friday','Saturday'],"Wed-Sat"],
      [['tue','fri','sat','sun'], "Tue, Fri-Sun"],
      [[5,6,7,1],"Fri-Mon"],
      [[1,5,6,7],"Mon, Fri-Sun"]
    ].each do |arr, str|
      assert_equal(str, DayRange.new(arr).to_s)
    end
      assert_raise(ArgumentError){ DayRange.new([1,8]).to_s }
  end
end
