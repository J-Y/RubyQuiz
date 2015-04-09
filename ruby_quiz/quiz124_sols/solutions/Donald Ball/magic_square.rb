# Ruby Quiz 124
# Donald Ball
# version 1.0

class MagicSquare
  SLANTS = [-1, 1]
  STARTS = [:top, :bottom, :left, :right]

  def initialize(n, slant=SLANTS[rand(SLANTS.length)], start=STARTS[rand(STARTS.length)])
    raise ArgumentError unless n > 0 && (n % 2) == 1
    raise ArgumentError unless SLANTS.include?(slant)
    raise ArgumentError unless STARTS.include?(start)
    @n = n
    @sum = (@n**3 + @n) / 2
    @values = Array.new(@n**2)
    if start == :top || start == :bottom
      c = @n / 2 
      dc = slant
      ddc = 0
      if start == :top
        r = 0
        dr = -1
        ddr = 1
      else
        r = -1
        dr = 1
        ddr = -1
      end
    else
      r = @n / 2
      dr = slant
      ddr = 0
      if start == :left
        c = 0
        dc = -1
        ddc = 1
      else
        c = -1
        dc = 1
        ddc = -1
      end
    end
    (1..@n).each do |i|
      (1..@n).each do |j|
        self[r, c] = @n*(i-1) + j
        unless j==@n
          r += dr
          c += dc
        else
          r += ddr
          c += ddc
        end
      end
    end
  end

  def offset(r, c)
    (r % @n) * @n + (c % @n)
  end

  def [](r, c)
    @values[offset(r, c)]
  end

  def []=(r, c, v)
    @values[offset(r, c)] = v
  end

  def range
    (0..@n-1)
  end

  def col(c)
    range.map {|r| @values[c + r*@n]}
  end

  def cols
    range.map {|c| col(c)}
  end

  def row(r)
    @values[r*@n, @n]
  end

  def rows
    range.map {|r| row(r)}
  end

  def diagonals
    [range.map {|i| @values[i*(@n+1)]}, range.map {|i| @values[(@n-1)*(i+1)]}]
  end

  def valid?
    (rows + cols + diagonals).each do |chunk|
      return false unless chunk.inject {|sum, v| sum += v} == @sum
    end
    true
  end

  def to_s
    def ojoin(a, sep)
      sep + a.join(sep) + sep
    end
    l = (@n**2).to_s.length
    sep = "+#{'-'*(@n*(l+2) + (@n-1))}+\n"
    ojoin(rows.map {|row| ojoin(row.map {|v| sprintf(" %#{l}d ", v)}, '|') + "\n"}, sep)
  end
end

if $0 == __FILE__
  puts MagicSquare.new(ARGV[0].to_i) if ARGV.length == 1
end