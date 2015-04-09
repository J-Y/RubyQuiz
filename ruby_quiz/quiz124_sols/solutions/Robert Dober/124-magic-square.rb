# vim: sts=2 sw=2 ft=ruby expandtab nu tw=0:
Usage = <<-EOS
  usage:
      ruby #{$0} [-t|--test] [-h|--html] <Square Order List>

      Prints Magic Squares for all indicated orders.
      Indicating -t also tests the results.
EOS
loop do
  case ARGV.first
    when "-t", "--test"
      require 'test-squares'
      ARGV.shift
    when "-h", "--html"
      require 'html-output'
      ARGV.shift
    when "-?", "--help", nil
      puts Usage
      exit
    when "--"
      ARGV.shift && break
    else
      break
  end
end

#
# This is a default output module, another output
# module called HTMLOutput is provided as an example
# how to pull in an appropriate Output module
# as plugin.
#
module Output
  def to_s decoration = false
    l = (@order*@order).to_s.size
    return  @data.map{ |line|
                        line.map{ |cell|  
                                   "%#{l}d" % cell 
                                }.join(" ")
                      }.join("\n") unless decoration

    sep_line = "+" << ( "-" * l.succ.succ << "+" ) * @order
    sep_line.dup << "\n" << 
    @data.map{ | line | "| " << line.map{ |cell| "%#{l}d" % cell }.join(" | ") << " |" }.
      zip( [sep_line] * @order ).flatten.join("\n")
  end
end

#
# The usage of cursors is slowing down the program a little
# bit but I feel it is still fast enough.
#
class Cursor
  attr_reader :cpos, :lpos
  def initialize order, lpos, cpos
    @order = order
    @lpos  = lpos
    @cpos  = cpos
  end

  def move ldelta, cdelta
    l = @lpos + ldelta
    c = @cpos + cdelta
    l %= @order
    c %= @order
    self.class.new @order, l, c
  end
  def next!
     @cpos += 1
     return if @cpos < @order
     @cpos = 0
     @lpos += 1
     @lpos %= @order
  end
end

#
# This is where the work is done, like
# testing and outputting and what was it?
# Ah yes storing the data.
#
class SquareData
  include Output
  include HTMLOutput rescue nil
  include TestSquare rescue nil
  def initialize order
    @order = order
    @data = Array.new( @order ){ Array.new( @order ) { nil } }
  end
  
  def peek(i, j); @data[i][j] end
  def poke(i, j, v); @data[i][j] = v end
  def [](c); @data[c.lpos][c.cpos] end
  def []=(c, v); @data[c.lpos][c.cpos] = v end

  def each_subdiagonal
    (@order/4).times do
      | line |
      (@order/4).times do
        | col |
        4.times do
          | l |
          4.times do
            | c |
            yield [ 4*line + l, 4*col + c ] if
            l==c || l+c == 3
          end
        end # 4.times do
      end # (@order/4).times do
    end # (@order/4).times do
  end

  def siamese_order
    model = self.class.new @order
    last = @order*@order
    @pos = Cursor.new @order, 0, @order/2
    yield @pos.lpos, @pos.cpos, peek( @pos.lpos, @pos.cpos )
    model[ @pos ] = true
    2.upto last do
      npos = @pos.move -1, +1
      npos = @pos.move +1, 0 if model[ npos ]
      model[ @pos = npos ] = true
      yield @pos.lpos, @pos.cpos, peek( @pos.lpos, @pos.cpos )
    end # @last.times do
  end
end # class SquareData

#
# The base class for Magic Squares it basically
# is the result of factorizing the three classes
# representing the three differnt cases, odd, even and
# double even.
# It's singleton class is used as a class Factory for
# the three implementing classes.
#
class Square

  def to_s decoration = false
    @data.to_s decoration
  end
  private
  def initialize order
    @order = order.to_i
    @last = @order*@order
    @data = SquareData.new @order
    compute
    @data.test rescue nil
  end

end

#
# The simplest case, the Siamese Order algorithm
# is applied.
#
class OddSquare < Square

  private
  def compute
    @pos = Cursor.new @order, 0, @order/2
    @data[ @pos ] = 1 
    2.upto @last do
      | n |
      npos = @pos.move -1, +1
      npos = @pos.move +1, 0 if @data[ npos ]
      @data[ @pos = npos ] = n
    end # @last.times do
  end

end # class OddSquare

#
# The Double Cross Algorithm is applied
# to double even Squares.
#
class DoubleCross < Square
  def compute
    pos = Cursor.new @order, 0, 0
    1.upto( @last ) do
      | n |
      @data[ pos ] = n
      pos.next!
    end # 1.upto( @last ) do
    @data.each_subdiagonal do
      | lidx, cidx |
      @data.poke lidx, cidx, @last.succ - @data.peek( lidx, cidx )
    end

  end
end

#
# And eventually we use the LUX algorithm of Conway for even 
# squares.
#
class FiatLux < Square
  L = [ [0, 1], [1, 0], [1, 1], [0, 0] ]
  U = [ [0, 0], [1, 0], [1, 1], [0, 1] ]
  X = [ [0, 0], [1, 1], [1, 0], [0, 1] ]
  def compute
    half = @order / 2
    lux_data = SquareData.new half
    n = half/2
    pos = Cursor.new half, 0, 0
    n.succ.times do 
      half.times do
        lux_data[ pos ] = L
        pos.next!
      end # half.times do
    end # n.succ.times do
    half.times do 
      lux_data[ pos ] = U
      pos.next!
    end # half.times do 
    lux_data.poke n, n, U
    lux_data.poke n+1, n, L
    2.upto(n) do
      half.times do
        lux_data[ pos ] = X
        pos.next!
      end
    end # 2.upto(half) do
   
    count = 1
    lux_data.siamese_order do
      | siam_row, siam_col, elem |
      elem.each do
        | r, c |
        @data.poke 2*siam_row + r, 2*siam_col + c, count
        count += 1
      end # elem.each do
    end # lux_data.siamese_order do
  end
end # class FiatLux

class << Square
  #
  # trying to call the ctors with consistent values only
  #
  protected :new
  def Factory arg
    arg = arg.to_i
    case arg % 4
      when 1, 3
        OddSquare.new arg
      when 0
        DoubleCross.new arg
      else
        FiatLux.new arg
    end
  end
end
ARGV.each do
  |arg|
  puts Square::Factory( arg ).to_s( true )
  puts
end

