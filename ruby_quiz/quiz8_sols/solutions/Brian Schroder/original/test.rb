require 'object_browser.rb'

class Term
  attr_reader :operator, :left, :right

  def each
    yield left
    yield right
  end
  
  def initialize(operator, left, right)
    @operator = operator
    @left = left
    @right = right
  end

  def value
    @value ||= left.value.send(:operator, right.value)
  end

  def to_s
    "(#{left} #{operator} #{right})"
  end
end

term = Term.new(:*, Term.new(:+, 10, 10), Term.new(:-, 10, 8))
puts term
term.extend Enumerable
browse_objects
puts term 
