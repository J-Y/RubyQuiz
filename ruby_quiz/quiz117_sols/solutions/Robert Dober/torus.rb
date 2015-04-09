# vim: sw=2 sts=2 nu tw=0 expandtab nowrap:
#
#

ICE = Class.new
VAPOR = Class.new
VACUUM = Class.new


###############################################################
#
# a small reference to Python ;)
#
###############################################################
def Torus( rows, cols, vapors, start = nil )
  Torus_.new( rows.to_i, cols.to_i, vapors.to_f, start )
end

class Torus_

  ###############################################################
  #
  #    Torus_
  #
  ###############################################################
  attr_reader :lines, :columns
  attr_reader :generation
  attr_accessor :formatter, :name
  def initialize rows, cols, vapors, start
    @lines = rows
    @columns = cols
    @vapors = vapors
    @generation = 0
    if start then
      @start = start.split("@").map{|e| e.to_i}
    else
      @start ||= [ rows/2, cols /2 ]
    end
    @nhoods = []  # we will store neighborhoods identified by
    # their upper left corner index, odd is for even generations
    # and even is for odd generations, which might seem odd.
    reset_values
    set_vapors
  end

  def [] line, col=nil
    return @values[line] unless col
    @values[line][col]
  end # def [](line, col=nil)
  def []= line, col, val
    @values[line][col] = val
  end
  def each_cell 
    (1..@lines).each do
      | line |
      (1..@columns).each do
        | column |
        yield @values[line-1][column-1], line-1, column-1
      end # (0..@columns).each do
    end # (0..@lines).each do
  end # def each_cell &blk

  def each_line
    @values.each{ |line| yield line }
  end

  def each_nbh
    r = c = @generation % 2
    loop do
      yield @nhoods[ linear_idx( r, c ) ] ||= 
          Neighborhood.new( self, r, r.succ % @lines, c, c.succ % @columns )
      c += 2
      r += 2 unless c < @columns
      return unless r < @lines
      c %= @columns
      r %= @lines
    end
  end

  def set_from_str str
    @values = []
    str.strip.split("\n").each do
      | line_str |
      @values << []
      line_str.each_byte do
         | char |
         @values.last << case char.chr
                          when ICE.to_s
                            ICE
                          when VACUUM.to_s
                            VACUUM
                          when VAPOR.to_s
                            VAPOR
                         end

      end
    end
  end

  def start_sim
    until no_more_vapor? do
      tick
      write
    end
  end # def start_sim

  def tick
    puts "Simulation #{@name} generation #{@generation}:"
    @generation += 1
    each_nbh do
      | nbh |
      nbh.recalc
    end 
  end

  private

  def no_more_vapor?
    ! @values.any?{ |line|
      line.any?{ |v| v == VAPOR }
    }
  end

  def reset_values
    @values = Array.new(@lines){
      Array.new(@columns){
        VACUUM
      }
    }
  end
  def set_vapors
    total = @lines * @columns
    v = ( @vapors *  (total-1) ).to_i
    x = [*0..total-2]
    at = []
    v.times do
      at << x.delete_at( rand(x.size) )
    end
    at.each do
      | index |
      l,c = matrix_idx index
      @values[l][c] = VAPOR
    end
    @values[@lines-1][@columns-1] = @values[@start.first][@start.last]
    @values[@start.first][@start.last] = ICE
  end # def set_vapors

  def linear_idx r, c
    r * @columns + c
  end
  def matrix_idx l
    return l / @columns, l % @columns
  end

  def write
    @formatter.to_file self, "output/#{@name}.%08d" % @generation
  end # def write
  
end # class Torus_

###############################################################
#
#    Neighborhood is implementing a 2x2 window to any object
#    that responds to #[]n,m and #[]=n,m,value
#    It implements the operation of rotation.
#
###############################################################
class Neighborhood 
  include Enumerable

  # Neighborhood gives us the following indexed view to the underlying
  # torus
  #     +---+---+     +-----------+-----------+
  #     | 0 | 1 |     | @top,@lft | @top,@rgt |
  #     +---+---+     +-----------+-----------+
  #     | 3 | 2 |     | @bot,@lft | @bot,@rgt |
  #     +---+---+     +-----------+-----------+
  #

  def initialize *args
    @torus, @top, @bottom, @left, @right = *args
    @names = [ [@top, @left], [@top, @right], [@bottom, @right], [@bottom, @left] ]
  end

  def [] n
    @torus[ *@names[n%4]  ]
  end
  def []= n, val
    @torus[ *@names[n%4] ] = val
  end

  def each
    4.times do
      | idx |
      yield self[idx]
    end
  end

  def recalc
    if any?{|v| v == ICE} then
      4.times do
        | idx |
        self[ idx ] = ICE if self[ idx ] == VAPOR
      end
    else
      rotate( rand(2) )
    end
  end

  def rotate dir
    x = self[0]
    3.times do
      | n |
      self[ n + 2*dir*n ] = self[ n + 1 + dir*2*n.succ ]
    end # 3.times do
    self[ 3 + 2 * dir ] = x
  end # def rotate dir

end # class Neighborhood

