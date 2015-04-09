# a quick helper method
module Enumerable
  def product 
    inject(1){|p,j| p*j}
  end
end

class PascalPrinter
  def initialize(n)
    @n = n

    # get middle element of last row to calculate cell size
    # nCr = n! / ( r! * (n-r)! )
    # this reduces to the following:
    a = @n/2
    r = @n - a
    max = ((r+1)..@n).product / (2..a).product

    @cell_size = max.to_s.size
    @cell_size += 1 if (@cell_size % 2).zero? # require odd cell size
    @row_size = (@cell_size + 1) * @n  - 1
  end

  def next_row(a)
    j = k = 0;
    a.map { |i|
      k = i + j;
      j = i;
      k
    } + [1]
  end

  def row_to_s(row)
    mid = row.size / 2 - 1
    i = 0
    out = row.collect { |v|
      s = v.to_s
      pad = (@cell_size - s.size)
      lpad = pad / 2
      rpad = pad - lpad
      lpad, rpad = rpad, lpad if i <= mid
      i+= 1
      (' ' * lpad) + s + (' ' * rpad)
    }.join(" ")

    ((' ' * ((@row_size - out.size) / 2)) + out)
  end

  def output
    a=[]
    @n.times { puts row_to_s(a=next_row(a)) }
  end
end

p = PascalPrinter.new(ARGV[0].to_i)
p.output
