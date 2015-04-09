require 'object_browser_gtk'

class Term
  attr_reader :operator, :left, :right

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
ObjectBrowser::UI::Gtk::browse(term)
puts term 
