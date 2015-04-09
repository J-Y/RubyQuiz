require 'rparsec/rparsec'

class Fixnum
  def to_bytes
      if self >= -32768 && self <= 32767
          a = [0x01]
          a << ((self & 0x0000FF00) >> 8)
          a << ((self & 0x000000FF))
      else
          a = [0x02]
          a << ((self & 0xFF000000) >> 24)
          a << ((self & 0x00FF0000) >> 16)
          a << ((self & 0x0000FF00) >> 8)
          a << ((self & 0x000000FF))
      end
  end
end
class Symbol
  def to_bytes
      case self
      when :+
          [0x0a]
      when :-
          [0x0b]
      when :*
          [0x0c]
      when :**
          [0x0d]
      when :/
          [0x0e]
      when :%
          [0x0f]
      end
  end

  def to_proc
      proc { |x| x.send self }
  end
end

class Array
  alias to_bytes to_a
end

class Compiler
  include Parsers
  include Functors
  def self.compile str
      new.parser.parse str
  end

  def func sym
      proc { |x, y| [x,y,sym].map(&:to_bytes).flatten }
  end

  def parser
      ops = OperatorTable.new do |t|
          t.infixl(char(?+) >> func(:+), 20)
          t.infixl(char(?-) >> func(:-), 20)
          t.infixl(char(?*) >> func(:*), 40)
          t.infixl(char(?/) >> func(:/), 40)
          t.infixl(char(?%) >> func(:%), 40)
          t.infixl(string('**') >> func(:**), 60)
          t.prefix(char(?-) >> Neg, 80)
      end
      expr = nil
      term = integer.map(&To_i) | char('(') >> lazy{expr} << char(')')
      delim = whitespace.many_
      expr = delim >> Expressions.build(term, ops, delim)
  end
end
