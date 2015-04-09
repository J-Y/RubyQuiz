require "test/unit"

require "word_filter"

class TestWordFilter < Test::Unit::TestCase
  def setup
    @filter = WordFilter.new
  end
  
  def test_filter_word
    assert_equal(false, @filter.pick("A"))
    assert_equal(true, @filter.pick("bad"))
  end
end