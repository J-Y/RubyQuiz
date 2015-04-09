# Justin Ethier
# December 2007
# Test cases for Solution to Ruby Quiz 148 - Postfix to Infix
# (http://www.rubyquiz.com/quiz148.html)

require 'postfix_to_infix.rb'
require 'test/unit'

class TestPostfixToInfix< Test::Unit::TestCase

  def test_with_parens
    assert_equal('2 * (3 + 5)', PostfixToInfix.translate('2 3 5 + *'))  
    assert_equal('56 * (34 + 213.7) - 678', PostfixToInfix.translate('56 34 213.7 + * 678 -'))
    assert_equal('1 + (56 + 35) / (16 - 9)', PostfixToInfix.translate('1 56 35 + 16 9 - / +'))
    assert_equal('5 + 12 * (10 - 4) - 8 / 4 / 2', PostfixToInfix.translate('5 12 10 4 - * + 8 4 / 2 / -'))
  end

end