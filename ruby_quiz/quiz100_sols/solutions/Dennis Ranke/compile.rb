require 'English'

class Compiler
  def self.compile(expr)
    return self.new(expr).compile.unpack('C*')
  end

  def initialize(expr)
    # a very simple tokenizer
    @tok = []
    until expr.empty?
      case expr
      when /\A\s+/  # skip whitespace
      # don't tokenize '1-1' as '1', '-1'
      when (@tok.last.is_a? Integer) ? /\A\d+/ : /\A\-?\d+/
        @tok << $MATCH.to_i
      # any other character and '**' are literal tokens
      when /\A\*\*|./
        @tok << $MATCH
      end
      expr = $POSTMATCH
    end
  end

  def compile
    code = compile_expr(0)
    raise "syntax error" unless @tok.empty?
    return code
  end

private

  OPS = {'+'=>0xa, '-'=>0xb, '*'=>0xc, '**'=>0xd, '/'=>0xe, '%'=>0xf}

  def compile_expr(level)
    # get the tokens to parse at this precedence level
    tok = [['+', '-'], ['*', '/', '%'], ['**']][level]
    if tok
      # if we are to actually parse a bi-op, do so
      left = compile_expr(level + 1)
      # for left-associative ops, find as many ops in a row as possible
      while tok.include?(@tok.first)
        op = OPS[@tok.shift]
        # '**' is right-associative, so add a special case for that
        right = compile_expr(op == OPS['**'] ? level : level + 1)
        left << right + op.chr
      end
      return left
    end
    # if we are at a level higher than the ops, try to parse an
    # atomic - either a numeral or an expression in paranthesis
    tok = @tok.shift
    if tok == '('
      expr = compile_expr(0)
      raise "')' expected" unless @tok.shift == ')'
      return expr
    end
    raise 'number expected' unless tok.is_a? Integer
    return (tok < -32768 || tok > 32767) ? [2, tok].pack('CN') :
            [1, tok].pack('Cn')
  end
end

if $0 == __FILE__
  p Compiler.compile(ARGV[0])
end
