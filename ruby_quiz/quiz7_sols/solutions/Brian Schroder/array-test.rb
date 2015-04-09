#!/usr/bin/ruby

require 'test/unit'
require 'countdown'

class TC_array_partitions < Test::Unit::TestCase
  PARTITIONS3 = [[[1], [2,3]], [[1,2], [3]], [[1,3], [2]]]
  PARTITIONS5 = [[[1], [2, 3, 4, 5]], [[1, 2], [3, 4, 5]], [[1, 2, 3], [4, 5]], [[1, 2, 3, 4], [5]], [[1, 2, 3, 5], [4]],
    [[1, 2, 4], [3, 5]], [[1, 2, 4, 5], [3]], [[1, 2, 5], [3, 4]], [[1, 3], [2, 4, 5]], [[1, 3, 4], [2, 5]], [[1, 3, 4, 5], [2]],
    [[1, 3, 5], [2, 4]], [[1, 4], [2, 3, 5]], [[1, 4, 5], [2, 3]], [[1, 5], [2, 3, 4]]]
  def test_each_partition
    partitions = []
    [1,2,3].each_partition do | p1, p2 | partitions << [p1.sort, p2.sort] end
    assert_equal(PARTITIONS3,  partitions.sort)
    partitions = []
    [1,2,3,4,5].each_partition do | p1, p2 | partitions << [p1.sort, p2.sort] end
    assert_equal(PARTITIONS5,  partitions.sort)
  end
end
