require 'test/unit'
require 'postfix_to_infix'

class PostfixToInfixTest < Test::Unit::TestCase
  VALID_CASES = [
    # { :postfix => '', :infix_verbose => '', :infix_preferred => '' }
    { :postfix => '2 3 -', :infix_verbose => '(2 - 3)', :infix_preferred => '2 - 3' },
    { :postfix => '2 3 5 + *', :infix_verbose => '(2 * (3 + 5))', :infix_preferred => '2 * (3 + 5)' },
    { :postfix => '56 34 213.7 + * 678 -', :infix_verbose => '((56 * (34 + 213.7)) - 678)', :infix_preferred => '56 * (34 + 213.7) - 678' },
    { :postfix => '1 56 35 + 16 9 - / +', :infix_verbose => '(1 + ((56 + 35) / (16 - 9)))', :infix_preferred => '1 + (56 + 35) / (16 - 9)' },
  ]
  
  def test_initialize_without_parameter_should_raise_exception
    assert_raise(ArgumentError) { PostfixToInfix.new }
  end
  
  def test_initialize_with_incorrect_parameter_should_raise_exception
    assert_raise(RuntimeError) { PostfixToInfix.new(1) }
    assert_raise(RuntimeError) { PostfixToInfix.new([]) }
    assert_raise(RuntimeError) { PostfixToInfix.new({}) }
  end
  
  def test_convert_sample_cases_verbose
    VALID_CASES.each do |sample|
      assert_nothing_raised(Exception) { ps2i = PostfixToInfix.new(sample[:postfix]) }
      ps2i = PostfixToInfix.new(sample[:postfix])
      assert_equal(sample[:infix_verbose], ps2i.convert)
    end
  end
end