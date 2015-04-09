module DiceRoller

  RollMethod = '.roll'

  def lex(str)
    tokens = str.scan(/(00)|([-*\/()+d%0])|([1-9][0-9]*)|(.+)/)
    tokens.each_index { |i|
      tokens[i] = tokens[i].compact[0]
      if not /^(00)|([-*\/()+d%0])|([1-9][0-9]*)$/ =~ tokens[i]
        if /^\s+$/ =~ tokens[i]
          tokens[i] = nil
        else
          fail "Found garbage in expression: '#{tokens[i]}'"
        end
      end
    }
    return tokens.compact
  end

  def validate_and_cook(tokens)
    oper = /[-*\/+d]/
    num = /(\d+)|%/
    last_was_op = true
    paren_depth = 0
    prev = ''
    working = []
    tokens.each_index { |i|
      tok = tokens[i]
      if num =~ tok
        fail 'A number cannot follow an expression!' if not last_was_op
        fail 'Found spurious zero or number starting with zero!' if tok == '0'
        if ( tok == '00' || tok == '%' )
          fail 'Can only use % or 00 after d!' if prev != RollMethod
          tokens[i] = 100
          tok = 100
        else
          tok = tok.to_i
        end
        if prev == RollMethod
          working << "(#{tok})"
        else
          working << tok
        end
        last_was_op = false
      elsif oper =~ tok
        tok = RollMethod if tok == 'd'
        if last_was_op
          #handle case of dX meaning 1dX
          if tok == RollMethod
            fail 'A d cannot follow a d!' if prev == RollMethod
            working << 1
          else
            fail 'An operator cannot follow a operator!'
          end
        end
        working << tok
        last_was_op = true
      elsif tok == "("
        fail 'An expression cannot follow an expression!' if not last_was_op
        paren_depth += 1
        working << tok
      elsif tok == ")"
        fail 'Incomplete expression at close paren!' if last_was_op
        fail 'Too many close parens!' if paren_depth < 1
        paren_depth -= 1
        last_was_op = false
        working << tok
      else #what did I miss?
        fail "What kind of token is this? '#{tok}'"
      end
      prev = tok
    }
    fail 'Missing close parens!' if paren_depth != 0
    return working
  end

  def parse_dice(str)
    tokens = lex(str)
    return validate_and_cook(tokens).to_s
  end

end

class Fixnum
  def roll(die)
    fail "Die count must be nonnegative: '#{self}'" if self < 0
    fail "Die size must be positive: '#{die}'" if die < 1
    return (1..self).inject(0) { |sum, waste| sum + (rand(die)+1) }
  end
end

class Dice

  def initialize(expression)
    @expression = parse_dice(expression)
  end

  def roll
    return (eval @expression)
  end

  private

  include DiceRoller

end
