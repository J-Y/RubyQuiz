require 'test/unit'
require 'pascal'

class TestPascal < Test::Unit::TestCase
  def test_class_exists
    assert_kind_of Class, Pascal
  end
  
  def test_nth_row_of_1
    assert_equal [1], Pascal.nth_row(1)
  end
  
  def test_nth_row_2
    assert_equal [1,1], Pascal.nth_row(2)
  end
  
  def test_nth_row_3
    assert_equal [1,2,1], Pascal.nth_row(3)
  end
  
  def test_nth_row_4
    assert_equal [1,3,3,1], Pascal.nth_row(4)
  end
  
  def test_format_rows_upto_1
    assert_equal "1", Pascal.format_rows_upto(1)
  end
  
  def test_format_rows_upto_2
    assert_equal " 1 \n1 1", Pascal.format_rows_upto(2)
  end
  
  def test_format_rows_upto_3
    assert_equal "  1  \n 1 1 \n1 2 1", Pascal.format_rows_upto(3)
  end
  
  def test_format_rows_upto_6
    assert_equal "          1           \n        1   1         \n      1   2   1       \n    1   3   3   1     \n  1   4   6   4   1   \n1   5   10  10  5   1 ", Pascal.format_rows_upto(6)
  end
  
  def test_element_width_row_1
    assert_equal 1, Pascal.element_width(1)
  end
  
  def test_element_width_row_6
    assert_equal 2, Pascal.element_width(6)
  end
  
  def test_element_width_row_10
    assert_equal 3, Pascal.element_width(10)
  end
end