#!/usr/bin/env ruby

class Atom
  def initialize(arg)
    @data = arg
  end
  def to_s
    @data.to_s
  end
  def to_a
    [@data]
  end
  def eval
    Kernel.eval(@data)
  end
  def radd(other)
    other.add(self)
  end
  def add(other)
    Sum.new(self, other)
  end
  def rsub(other)
    other.sub(self)
  end
  def sub(other)
    Difference.new(self, other)
  end
  def rmul(other)
    other.mul(self)
  end
  def mul(other)
    Product.new(self, other)
  end
  def rdiv(other)
    other.div(self)
  end
  def div(other)
    Quotient.new(self, other)
  end
end

class Group < Atom
  def initialize(expr)
    @expr = expr
  end
  def to_s
    "(#{@expr})"
  end
  def to_a
    @expr.to_a
  end
  def eval
    @expr.eval
  end
end

class Sum < Atom
  def initialize(left, right)
    @left = left
    @right = right
  end
  def to_s
    "#{@left} + #{@right}"
  end
  def to_a
    @left.to_a.concat(@right.to_a) << :+
  end
  def eval
    @left.eval + @right.eval
  end
  def radd(other)
    @left.radd(other).add(@right)
  end
  def rsub(other)
    @left.rsub(other).sub(@right)
  end
  def rmul(other)
    other.mul(Group.new(self))
  end
  def mul(other)
    Product.new(Group.new(self), other)
  end
  def rdiv(other)
    other.div(Group.new(self))
  end
  def div(other)
    Quotient.new(Group.new(self), other)
  end
end

class Difference < Sum
  def to_s
    "#{@left} - #{@right}"
  end
  def to_a
    @left.to_a.concat(@right.to_a) << :-
  end
  def eval
    @left.eval - @right.eval
  end
  def radd(other)
    @left.radd(other).sub(@right)
  end
  def rsub(other)
    @left.rsub(other).add(@right)
  end
end

class Product < Atom
  def initialize(left, right)
    @left = left
    @right = right
  end
  def to_s
    "#{@left}*#{@right}"
  end
  def to_a
    @left.to_a.concat(@right.to_a) << :*
  end
  def eval
    @left.eval * @right.eval
  end
  def rmul(other)
    @left.rmul(other).mul(@right)
  end
  def rdiv(other)
    # could do this to reduce grouping and stack depth
    # but this will increase expensive divisions
    # @left.rdiv(other).div(@right)
    other.div(Group.new(self))
  end
end

class Quotient < Product
  def to_s
    "#{@left}/#{@right}"  # had a * operator here before, whoops!
  end
  def to_a
    @left.to_a.concat(@right.to_a) << :/
  end
  def eval
    @left.eval / @right.eval
  end
  def rmul(other)
    @left.rmul(other).div(@right)
  end
  def rdiv(other)
    @left.rdiv(other).mul(@right)
  end
end

stack = []
ARGV.each { |arg|
  arg.scan(/\S+/) { |token|
    case token
      when "+" : stack.push(stack.pop.radd(stack.pop))
      when "-" : stack.push(stack.pop.rsub(stack.pop))
      when "*" : stack.push(stack.pop.rmul(stack.pop))
      when "/" : stack.push(stack.pop.rdiv(stack.pop))
      else ; stack.push(Atom.new(token))
    end
  }
}

stack.each { |expr|
  puts("#{expr.to_a.join(' ')} => #{expr} =>  #{expr.eval}")
}
