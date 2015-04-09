#tc_magic_square.rb
require 'test/unit'

require 'magic_square'

class TestOddMagicSquare < Test::Unit::TestCase

  def setup
    @n = 5
    @odd_magic_square = OddMagicSquare.new(@n)
    @odd_magic_square.iterate_square
    @square = @odd_magic_square.square
    @sum = (@n ** 2 / 2 + 1) * @n
  end

  def test_sum_row_and_col
    @n.times do |t|
      assert_equal @sum, get_sum_column(t)
      assert_equal @sum, get_sum_row(t)
    end
    assert_equal @sum, get_sum_diagonal('left')
    assert_equal @sum, get_sum_diagonal('right')
  end

  private

  def get_sum_column(i)
    sum = 0
    @n.times do |t|
      sum += @square[t][i]
    end
    sum
  end

  def get_sum_row(i)
    sum = 0
    @n.times do |t|
      sum += @square[i][t]
    end
    sum
  end

  def get_sum_diagonal(alignment)
    if alignment == 'left' then
      sum = i = 0
      @n.times do |t|
        sum += @square[i][i]
        i = i + 1
      end
      return sum
    elsif alignment == 'right' then
      sum = 0
      i = @n - 1
      @n.times do |t|
        sum += @square[i][i]
        i = i - 1
      end
      return sum
    else
      raise 'Alignment must be left or right.'
    end
  end

end
