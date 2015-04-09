#!/usr/bin/ruby

class Fixnum
  def d(b)
    (1..self).inject(0) {|s,x| s + rand(b) + 1}
  end
end

class Dice

  def initialize(exp)
    @expr = to_rpn(exp)
  end

  def roll
    stack = []
    @expr.each do |token|
      case token
        when /\d+/
          stack << token.to_i
        when /[-+*\/d]/
          b = stack.pop
          a = stack.pop
          stack << a.send(token.to_sym, b)
      end
    end
    stack.pop
  end

  private

  def to_rpn(infix)
    stack, rpn, last = [], [], nil
    infix.scan(/\d+|[-+*\/()d%]/) do |token|
      case token
        when /\d+/
          rpn << token
        when '%'
          rpn << "100"
        when /[-+*\/d]/
          while stack.any? && stronger(stack.last, token)
            rpn << stack.pop
          end
          rpn << "1" unless last =~ /\d+|\)|%/
          stack << token
        when '('
          stack << token
        when ')'
          while (op = stack.pop) && (op != '(')
            rpn << op
          end
      end
      last = token
    end
    while op = stack.pop
      rpn << op
    end
    rpn
  end

  def stronger(op1, op2)
    (op1 == 'd' && op2 != 'd') || (op1 =~ /[*\/]/ && op2 =~ /[-+]/)
  end

end

if $0 == __FILE__
  d = Dice.new(ARGV[0])
  (ARGV[1] || 1).to_i.times { print "#{d.roll} " }
end
