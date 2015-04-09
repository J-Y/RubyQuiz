class Array
  # iterate through pairs of consecutive elements
  def each_pair
    (0..size-2).each do |i|
      yield(self[i], self[i+1])
    end
  end
end

class Pascal
  def initialize(n)
    @triangle = [[1]]
    2.upto(n) do
      @triangle << calc_row(lastrow)
    end
  end

  def lastrow; @triangle[-1]; end

  # calculate row given the previous row
  def calc_row(previous)
    thisrow = [1]
    previous.each_pair do |x, y|
      thisrow << x + y
    end
    thisrow << 1
  end

  def to_s
    cellwidth   = lastrow.max.to_s.size
    indentation = lastrow.size - 1
    emptycell   = ' ' * cellwidth
    s = ''
    @triangle.each do |row|
      s << emptycell * indentation
      s << row.map{|cell| cell.to_s.center(cellwidth)}.join(emptycell)
      s << "\n"
      indentation -= 1
    end
    s
  end
end

if $0 == __FILE__
  puts Pascal.new(ARGV[0].to_i).to_s
end
