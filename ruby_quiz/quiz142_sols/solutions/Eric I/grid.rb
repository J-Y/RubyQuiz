# Square grid (order n**2, where n is an integer > 1). Grid points are
# spaced on the unit lattice with (0, 0) at the lower left corner and
# (n-1, n-1) at the upper right.

class Grid
  attr_reader :n, :pts, :min
  def initialize(n)
    raise ArgumentError unless Integer === n && n > 1
    @n = n
    @pts = []
    n.times do |i|
      x = i.to_f
      n.times { |j| @pts << [x, j.to_f] }
    end
    # @min is length of any shortest tour traversing the grid.
    @min = n * n
    @min += Math::sqrt(2.0) - 1 if @n & 1 == 1
  end
end
