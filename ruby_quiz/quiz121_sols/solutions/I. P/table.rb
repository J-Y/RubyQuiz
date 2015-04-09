# An interface to subsequent tables

class Table

  def initialize
    @table = {}
    compose
  end

  def compose
  end

  def [](value)
    @table[value]
  end  

end
