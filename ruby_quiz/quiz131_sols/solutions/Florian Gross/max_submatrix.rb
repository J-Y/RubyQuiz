class Array
  def transpose_zip(&block)
    first, rest = self[0], self[1 .. -1]
    first.zip(*rest, &block)
  end
end

require 'matrix'

class Matrix
  def each_cont_sub_matrix(&block)
    return enum_for(__method__) unless block_given?

    to_a.each_cont_sub_array do |rows|
      rows.map { |row| row.each_cont_sub_array }.transpose_zip(&block)
    end
  end
end

Matrix[
  [-1, +2, +5],
  [-4, +5, -2],
  [+8, +4, -3]
].each_cont_sub_matrix.max_by { |ary| ary.flatten.inject(&:+) } # => [[-1, 2], [-4, 5], [8, 4]]
