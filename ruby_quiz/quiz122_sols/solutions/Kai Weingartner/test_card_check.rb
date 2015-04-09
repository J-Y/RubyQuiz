require 'card_check'
require 'test/unit'
class TestCardCheck < Test::Unit::TestCase
  def test_validity
    assert_equal(true, CardCheck.new("4408041234567893").is_valid?)
    assert_equal(false, CardCheck.new("4417123456789112").is_valid?)
  end
  
  def test_type
    assert_equal('Visa', CardCheck.new("4408041234567893").type)
    assert_equal('AMEX', CardCheck.new("340804123456789").type)
    assert_equal('Discover', CardCheck.new("6011440804123456").type)
    assert_equal('MasterCard', CardCheck.new("5308041234567893").type)
    assert_equal('Visa', CardCheck.new("4408041234567").type)
    assert_equal('Unknown', CardCheck.new("9408041234567893").type)
  end
end
