# vim: sts=2 sw=2 ft=ruby expandtab nu tw=0:

module TestSquare
  def assert cdt, msg
    return $stderr.puts( "#{msg} . . . . . ok" ) if cdt
    raise Exception, msg << "\n" << to_s
  end
  def test
    dia1 = dia2 = 0
    @order.times do
      | idx |
      dia1 += peek( idx, idx )
      dia2 += peek( idx, -idx.succ )
    end # @lines.each_with_index do
    assert dia1==dia2, "Both diagonals"
    @order.times do 
      | idx1 |
      col_n = row_n = 0
      @order.times do 
        | idx2 |
        col_n += peek idx2, idx1
        row_n += peek idx1, idx2
      end
      assert dia1 == col_n, "Col #{idx1}"
      assert dia1 == row_n, "Row #{idx1}"
    end # @lines.each_with_index do
  end # def test

  def is_ok?
    dia1 = dia2 = 0
    @order.times do
      | idx |
      dia1 += peek( idx, idx )
      dia2 += peek( idx, -idx.succ )
    end # @lines.each_with_index do
    return false unless dia1==dia2
    @order.times do 
      | idx1 |
      col_n = row_n = 0
      @order.times do 
        | idx2 |
        col_n += peek idx2, idx1
        row_n += peek idx1, idx2
      end
      return false unless dia1 == col_n
      return false unless dia1 == row_n
    end # @lines.each_with_index do
    true
    
  end

end
