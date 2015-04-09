require 'pascal'
require 'test/unit'

class PascalTest < Test::Unit::TestCase
  def test_1
    expected = "1\n"
    assert_equal expected, Pascal.new(1).to_s
  end

  def test_2
    assert_equal <<EXPECTED, Pascal.new(2).to_s
1
1 1
EXPECTED
  end

  def test_3
    assert_equal <<EXPECTED, Pascal.new(3).to_s
  1
1 1
1 2 1
EXPECTED
  end

  def test_10
    assert_equal <<EXPECTED, Pascal.new(10).to_s
                            1
                         1     1
                      1     2     1
                   1     3     3     1
                1     4     6     4     1
             1     5    10    10     5     1
          1     6    15    20    15     6     1
       1     7    21    35    35    21     7     1
    1     8    28    56    70    56    28     8     1
1     9    36    84    126   126   84    36     9     1
EXPECTED
  end
end
