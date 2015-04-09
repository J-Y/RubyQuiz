#!/usr/bin/env ruby
#
#  Dan Manges - http://www.dcmanges.com
#  Ruby Quiz #124 - http://rubyquiz.com/quiz124.html

module ArrayExtension
  def sum
    inject { |x,y| x + y } || 0
  end
end
Array.send :include, ArrayExtension

class MagicSquare
  def initialize(size)
    @size = size
  end

  def row
    result
  end

  def column
    row[0].zip(*row[1..-1])
  end

  def diagonal
    first_diagonal  = (0...@size).map { |index| row[index][index] }
    second_diagonal = (0...@size).map { |index| row[index][@size-index-1] }
    [first_diagonal, second_diagonal]
  end

  protected

  def result
    @result ||= MagicSquareGenerator.new(@size).generate
  end

  def method_missing(method, *args, &block)
    result.send(method, *args, &block)
  end
end

class MagicSquareGenerator
  def initialize(size)
    @size = size
  end

  def generate
    square = (0...@size).map { [nil] * @size }
    x, y = 0, @size / 2
    1.upto(@size**2) do |current|
      x, y = add(x,2), add(y,1) if square[x][y]
      square[x][y] = current
      x, y = add(x, -1), add(y, -1)
    end
    square
  end

  private

  def add(x,y)
    value = x + y
    value = @size + value if value < 0
    value = value % @size if value >= @size
    value
  end

end

class MagicSquareFormatter
  def initialize(magic_square)
    @magic_square = magic_square
  end

  def formatted_square
    formatting = "|" + " %#{number_width}s |" * size
    rows = @magic_square.map { |row| formatting % row }
    body = rows.join("\n#{row_break}\n")
    "#{row_break}\n#{body}\n#{row_break}"
  end

  private

  def row_break
    dashes = '-' * (row_width-2)
    '+' + dashes + '+'
  end

  def number_width
    (@magic_square.size**2).to_s.length
  end

  def row_width
    (number_width+3) * size + 1
  end

  def size
    @magic_square.size
  end
end

if ARGV.first =~ /^\d+$/
  size = ARGV.first.to_i
  puts "Generating #{size}x#{size} magic square..."
  magic_square = MagicSquare.new(size)
  puts MagicSquareFormatter.new(magic_square).formatted_square
elsif __FILE__ == $0
  require 'test/unit'
  class MagicSquare3x3Test < Test::Unit::TestCase

    def setup
      @magic_square = MagicSquare.new(3)
    end

    def test_sum_of_rows_columns_and_diagonals
      (0...3).each do |index|
        assert_equal 15, @magic_square.row[index].sum
        assert_equal 15, @magic_square.column[index].sum
      end
      assert_equal 15, @magic_square.diagonal[0].sum
      assert_equal 15, @magic_square.diagonal[1].sum
    end

    def test_expected_values
      assert_equal [1,2,3,4,5,6,7,8,9], @magic_square.flatten.sort
    end

  end

  class MagicSquare9x9Test < Test::Unit::TestCase
    def setup
      @magic_square = MagicSquare.new(9)
    end

    def test_sum_of_rows_columns_and_diagonals
      (0...9).each do |index|
        assert_equal 369, @magic_square.row[index].sum
        assert_equal 369, @magic_square.column[index].sum
      end
      assert_equal 369, @magic_square.diagonal[0].sum
      assert_equal 369, @magic_square.diagonal[1].sum
    end

    def test_expected_values
      assert_equal (1..81).to_a, @magic_square.flatten.sort
    end
  end
end
