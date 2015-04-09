require 'test/unit'
require 'weird'

class TestWeird < Test::Unit::TestCase
  def test_proper_divisors
    assert_equal [1], 11.proper_divisors
    assert_equal [1, 2, 3, 4, 6], 12.proper_divisors
    assert_equal [1, 2, 3, 5, 6, 9, 10, 15, 18, 30, 45], 90.proper_divisors
  end
  
  def test_find_partition_from
    assert_equal nil, 2.send(:find_partition_from, [1])
    assert_equal [2], 2.send(:find_partition_from, [2])
    assert_equal [4,1], 5.send(:find_partition_from, [4, 3, 2, 1])
    assert_equal [175, 70, 50, 35, 14, 5, 1], 350.send(:find_partition_from, 350.proper_divisors.reverse)
  end
  
  def test_abundant
    assert_equal [12, 18, 20, 24], (1..25).find_all { |i| i.abundant? }
    assert 945.abundant?, "945 not abundant" # test an odd one for good measure, no real reason why
  end
  
  def test_semiperfect
    assert_equal [6, 12, 18, 20, 24], (1..25).find_all { |i| i.semiperfect? }
  end
  
  def test_weird
    assert 70.weird?, "70 not weird"
    assert !90.weird?, "90 weird"
  end
  
  def test_weird_numbers
    assert_equal [70, 836], weird_numbers_less_than(1000)
    assert_equal [], weird_numbers_less_than(70)
  end
end