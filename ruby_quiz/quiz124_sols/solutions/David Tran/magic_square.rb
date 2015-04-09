#---------------------------------------------------------------#
#                                                               #
#  Program   : Magic Square                                     #
#  Author    : David Tran                                       #
#  Date      : 2007-05-20                                       #
#  Blog      : http://davidtran.doublegifts.com/blog/?p=27      #
#  Reference : http://mathworld.wolfram.com/MagicSquare.html    #
#                                                               #
#---------------------------------------------------------------#
class MagicSquare

  def initialize(size = 3)
    raise "Error: size must greater than 2." if size < 3
    @magic_square = if (size % 2 != 0)
      OddMagicSquare.new(size)
    elsif (size % 4 == 0)
      DoublyEvenMagicSquare.new(size)
    else
      SinglyEvenMagicSquare.new(size)
    end
  end

  def size
    @magic_square.size
  end

  def [](i,j)
    @magic_square[i,j]
  end

  def to_s
    digits = (size * size).to_s.size
    divider = '+' + '-' * ((digits + 2) * size + (size - 1)) + "+\n"
    (0...size).inject(divider) do |s, i|
      (0...size).inject(s + "|") do |s, j|
        s + " #{self[i,j].to_s.rjust(digits)} |"
      end + "\n" + divider
    end
  end

  def is_magic_square?
    size = self.size
    n = size * size

    array = Array.new(n)
    (0...size).each do |i|
      (0...size).each do |j|
        index = self[i,j] - 1
        return false if (index < 0) || (index >= n) || array[index]
        array[index] = true
      end
    end
    return false unless array.all?

    sum = size * (size * size + 1) / 2
    (0...size).each do |i|
      return false if sum != (0...size).inject(0) { |s,j| s + self[i,j] }
      return false if sum != (0...size).inject(0) { |s,j| s + self[j,i] }
    end
    return false if sum != (0...size).inject(0) { |s,i| s + self[i,i] }
    return false if sum != (0...size).inject(0) { |s,i| s + self[i, size-1-i] }
    true
  end

  private
  #------------------------------------------------------------------#
  class OddMagicSquare
    attr_reader :size

    def initialize(size)
      @size = size
      n = @size * @size
      @array = Array.new(n)
      i, j = 0, @size/2
      (1..n).each do |v|
        @array[get_index(i,j)] = v
        a, b = i-1, j+1
        i, j = self[a,b] ? [i+1, j] : [a, b]
      end
    end

    def [](i, j)
      @array[get_index(i,j)]
    end

    private
    def get_index(i, j)
      (i % @size) * @size + (j % @size)
    end
  end
  #------------------------------------------------------------------#
  class DoublyEvenMagicSquare
    attr_reader :size

    def initialize(size)
      @size = size
    end

    def [](i, j)
      i, j = i % @size, j % @size
      value = (i * @size) + j + 1
      i, j = i % 4, j % 4
      ((i == j) || (i + j == 3)) ? (@size*@size+1-value) : value
    end
  end
  #------------------------------------------------------------------#
  class SinglyEvenMagicSquare
    attr_reader :size

    L = [4, 1, 2, 3]
    U = [1, 4, 2, 3]
    X = [1, 4, 3, 2]

    def initialize(size)
      @size = size
      @odd_magic_square = MagicSquare.new(@size/2)
    end

    def [](i, j)
      i, j = i % @size, j % @size
      ii, jj = i / 2, j / 2
      center = @size / 2 / 2
      value = @odd_magic_square[ii, jj]
      case
        when ii < center then L
        when ii == center then (jj == center) ? U : L
        when ii == center+1 then (jj == center) ? L : U
        else X
      end [i%2*2 + j%2] + 4 * (value - 1)
    end
  end
  #------------------------------------------------------------------#
end

if __FILE__ == $0
  puts MagicSquare.new(ARGV[0].to_i)
end
