# The original version of this file was written by Brian Candler.  It
# was then updated by Ken Bloom to include better error reporting.
#
# See:
#   http://www.rubyquiz.com/quiz144.html
#   http://www.iit.edu/~kbloom1/

require 'test/unit'
require 'time_window'

class TestTimeWindow < Test::Unit::TestCase
  def test_window_1
    s = "Sat-Sun; Mon Wed 0700-0900; Thu 0700-0900 1000-1200"
    w = TimeWindow.new(s)

    assert ! w.include?(Time.mktime(2007,9,25,8,0,0)),   "#{s.inspect} should not include Tue 8am"
    assert   w.include?(Time.mktime(2007,9,26,8,0,0)),   "#{s.inspect} should include Wed 8am"
    assert ! w.include?(Time.mktime(2007,9,26,11,0,0)),  "#{s.inspect} should not include Wed 11am"
    assert ! w.include?(Time.mktime(2007,9,27,6,59,59)), "#{s.inspect} should not include Thurs 6:59am"
    assert   w.include?(Time.mktime(2007,9,27,7,0,0)),   "#{s.inspect} should include Thurs 7am"
    assert   w.include?(Time.mktime(2007,9,27,8,59,59)), "#{s.inspect} should include Thurs 8:59am"
    assert ! w.include?(Time.mktime(2007,9,27,9,0,0)),   "#{s.inspect} should not include Thurs 9am"
    assert   w.include?(Time.mktime(2007,9,27,11,0,0)),  "#{s.inspect} should include Thurs 11am"
    assert   w.include?(Time.mktime(2007,9,29,11,0,0)),  "#{s.inspect} should include Sat 11am"
    assert   w.include?(Time.mktime(2007,9,29,0,0,0)),   "#{s.inspect} should include Sat midnight"
    assert   w.include?(Time.mktime(2007,9,29,23,59,59)),
    "#{s.inspect} should include Saturday one minute before midnight"
  end
  
  def test_window_2
    s = "Fri-Mon"
    w = TimeWindow.new(s)
    assert ! w.include?(Time.mktime(2007,9,27)), "#{s.inspect} should not include Thurs"
    assert   w.include?(Time.mktime(2007,9,28)), "#{s.inspect} should include Fri"
    assert   w.include?(Time.mktime(2007,9,29)), "#{s.inspect} should include Sat"
    assert   w.include?(Time.mktime(2007,9,30)), "#{s.inspect} should include Sun"
    assert   w.include?(Time.mktime(2007,10,1)), "#{s.inspect} should include Mon"
    assert ! w.include?(Time.mktime(2007,10,2)), "#{s.inspect} should not include Tues"
  end
  
  def test_window_nil
    w = TimeWindow.new("")
    assert w.include?(Time.mktime(2007,9,25,1,2,3)),"Empty string should include all times"
  end
end