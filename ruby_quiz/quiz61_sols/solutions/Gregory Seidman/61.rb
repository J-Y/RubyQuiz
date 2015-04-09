module DiceRoller

  class ArithOperator
    def initialize(left, op, right)
      @left = left
      @op = op
      @right = right
    end

    def to_i
      return (eval "#{@left.to_i}#{@op}#{@right.to_i}")
    end
  end

  class DieOperator
    #op is a dummy
    def initialize(left, op, right)
      @left = left
      @right = right
    end

    def to_i
      count = @left.to_i 
      fail "Die count must be nonnegative: '#{count}'" if count < 0
      die = @right.to_i
      fail "Die size must be positive: '#{die}'" if die < 1
      return (1..count).inject(0) { |sum, waste| sum + (rand(die)+1) }
    end
  end

  OpClass = { '+' => ArithOperator,
              '-' => ArithOperator,
              '*' => ArithOperator,
              '/' => ArithOperator,
              'd' => DieOperator }

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
          fail 'Can only use % or 00 after d!' if prev != 'd'
          tokens[i] = 100
          working << 100
        else
          working << tok.to_i
        end
        last_was_op = false
      elsif oper =~ tok
        if last_was_op
          #handle case of dX meaning 1dX
          if tok == 'd'
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
        working << :p_open
      elsif tok == ")"
        fail 'Incomplete expression at close paren!' if last_was_op
        fail 'Too many close parens!' if paren_depth < 1
        paren_depth -= 1
        last_was_op = false
        working << :p_close
      else #what did I miss?
        fail "What kind of token is this? '#{tok}'"
      end
      prev = tok
    }
    fail 'Missing close parens!' if paren_depth != 0
    return working
  end

  def parse_parens(tokens)
    working = []
    i = 0
    while i < tokens.length
      if tokens[i] == :p_open
        i += 1
        paren_depth = 0
        paren_tokens = []
        while (tokens[i] != :p_close) || (paren_depth > 0)
          if tokens[i] == :p_open
            paren_depth += 1
          elsif tokens[i] == :p_close
            paren_depth -= 1
          end
          paren_tokens << tokens[i]
          i += 1
        end
        working << parse(paren_tokens)
      else
        working << tokens[i]
      end
      i += 1
    end
    return working
  end

  def parse_ops(tokens, regex)
    fail "Something broke: len = #{tokens.length}" if tokens.length < 3 ||  (tokens.length % 2) == 0
    i = 1
    working = [ tokens[0] ]
    while i < tokens.length
      if regex =~ tokens[i].to_s
        op = OpClass[tokens[i]]
        lindex = working.length-1
        working[lindex] = op.new(working[lindex], tokens[i], tokens[i+1])
      else
        working << tokens[i]
        working << tokens[i+1]
      end
      i += 2
    end
    return working
  end

  #scan for parens, then d, then */, then +-
  def parse(tokens)
    working = parse_parens(tokens)
    fail "Something broke: len = #{working.length}" if (working.length % 2) == 0
    working = parse_ops(working, /^d$/) if working.length > 1
    fail "Something broke: len = #{working.length}" if (working.length % 2) == 0
    working = parse_ops(working, /^[*\/]$/) if working.length > 1
    fail "Something broke: len = #{working.length}" if (working.length % 2) == 0
    working = parse_ops(working, /^[+-]$/) if working.length > 1
    fail "Something broke: len = #{working.length}" if working.length != 1
    return working[0]
  end

  def parse_dice(str)
    tokens = lex(str)
    return parse(validate_and_cook(tokens))
  end

end

class Dice

  def initialize(expression)
    @expression = parse_dice(expression)
  end

  def roll
    return @expression.to_i
  end

  private

  include DiceRoller

end
