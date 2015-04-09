class NumberSpiral
  def initialize(n)
    @size = n
    @format = "%#{(n*n - 1).to_s.length+1}d"
    if n % 2 == 0
      @top_row = proc{|x| (x*(x-1)).upto(x*x-1) {|i| print_num(i) } }
      @bottom_row = proc{|x| ((x-1)*(x-1)).downto((x-1)*(x-2)) {|i| print_num(i) } }
      @middle_first = proc{|x,row| print_num(x*(x-1)-row) }
      @middle_last = proc{|x,row| print_num((x-2)*(x-2)-1+row) }
    else
      @top_row = proc{|x| ((x-1)*(x-2)).upto((x-1)*(x-1)) {|i| print_num(i) } }
      @bottom_row = proc{|x| (x*x-1).downto(x*(x-1)) {|i| print_num(i) } }
      @middle_first = proc{|x,row| print_num((x-1)*(x-2)-row) }
      @middle_last = proc{|x,row| print_num((x-1)*(x-1)+row) }
    end
  end

  def print_num(i)
    printf @format, i
  end

  def print_row(size, row)
    if row == 0
      @top_row.call(size)
    elsif row == size - 1
      @bottom_row.call(size)
    else
      @middle_first.call(size, row)
      print_row(size-2, row-1)
      @middle_last.call(size, row)
    end
  end

  def print_clockwise
    @size.times {|i| print_row(@size, i) ; puts ; puts if i < @size-1 }
  end
end

if ARGV.size == 0 or not ARGV[0] =~ /^\d+$/
  puts "Usage:  #$0 N"
  puts "Output:  Prints a \"spiral\" of numbers that fill a NxN square."
else
  NumberSpiral.new(ARGV[0].to_i).print_clockwise
end
