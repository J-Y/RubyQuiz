def fold(row, col, operations)

  def t2b(table)
    t1 = table[0...table.size/2].reverse
    t2 = table[table.size/2..-1]
    row = t1.size
    col = t1[0].size
    row.times { |r| col.times { |c| t2[r][c] = t1[r][c].reverse + t2[r][c] } }
    t2
  end

  def b2t(table)
    t2b(table.reverse).reverse
  end

  def l2r(table)
    t2b(table.transpose).transpose
  end

  def r2l(table)
    t2b(table.transpose.reverse).reverse.transpose
  end

  if 2**operations.size != row * col   ||
     operations =~ /[^TBLR]/           ||
     2**operations.gsub(/[LR]/,'').size != row
    raise "Error: parameters are not correct."
  end

  index = 0
  table = Array.new(row) { Array.new(col) { [index += 1] } }

  operations.each_byte do |op|
    table = case op
      when ?T : t2b(table)
      when ?B : b2t(table)
      when ?L : l2r(table)
      when ?R : r2l(table)
      else raise "Error: Invalid fold operation."
    end
  end

  table[0][0]
end

#========================================================================#

def check_fold(row, col, result)

  # find all combinations with binary 0 for row and 1 for column operation
  def all_orders(r, c) #
    return [2**c - 1] if (r <= 0)  # c bits of 1 is 2**c-1
    return [0]        if (c <= 0)  # r bits of 0 is 0
    table = []
    all_orders(r-1,c).each { |t| table << ((t << 1) + 0) }
    all_orders(r,c-1).each { |t| table << ((t << 1) + 1) }
    table
  end

  if row * col != result.size                     ||
     2 ** (Math.log(row)/Math.log(2)).to_i != row ||
     2 ** (Math.log(col)/Math.log(2)).to_i != col
    raise "Error: Parameters are not correct."
  end

  r = Integer(Math.log(row) / Math.log(2))
  c = Integer(Math.log(col) / Math.log(2))
  all_rc_orders = all_orders(r,c)

  row.times do |tb_operation|
    col.times do |lr_operation|
      all_rc_orders.each do |order|
        operations = ''
        tb_op = tb_operation
        lr_op = lr_operation
        (r+c).times do
          if (order & 1 == 0)
            operations += (tb_op & 1 == 0) ? 'T' : 'B'
            tb_op >>= 1
          else
            operations += (lr_op & 1 == 0) ? 'L' : 'R'
            lr_op >>= 1
          end
          order >>= 1
        end
        return operations if fold(row, col, operations) == result
      end
    end
  end
  "No solution."
end
