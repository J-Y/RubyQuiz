# Ruby quiz #84, Pascal's Triangle

class PascTri
  # You can consider the triangle to be a set of diagonals
  # in a 2-dimensional array.  This recursively calculates
  # the value of any cell in that array.  If speed was a
  # concern, you could make the array explicit, and cache
  # calculated values in it.
  def val(a, b)
    (a == 0 or b == 0) ? 1 : val(a-1, b) + val(a, b-1)
  end

  # return the values for a given row in the triangle,
  # i.e., a particular diagonal in the implicit array.
  def row(n)
    (0...n).map { |i| val(i, n-1-i) }
  end

  def print(row_total)
    # print using rows * 2 - 1 columns with a width
    # matching width of the largest number, which will
    # always be in the middle of the array section.
    cols = row_total * 2 - 1
    row_str = "%#{val(row_total/2, row_total/2).to_s.length}s" * cols + "\n"

    # we're going to use nil as a spacer where the data
    # shouldn't be.  We'll put spacers on each side of the
    # data portion, and intersperce the data array with nils,
    # simultaneously converting the data to strings to match
    # the print format.  A splat converts the array to a list
    # of args for printf.
    (1..row_total).each { |row|
      # the spacer is the number of columns, less the amount
      # taken up by the data portion, split into two sections
      # (the number is always even) for the left and right.
      spacer = [nil] * ((cols - (row * 2 - 1)) / 2)
      printf(row_str, *(spacer + row(row).map { |x| [x.to_s, nil]}.flatten[0...-1] + spacer))
    }
  end
end

PascTri.new.print(ARGV[0].to_i)
