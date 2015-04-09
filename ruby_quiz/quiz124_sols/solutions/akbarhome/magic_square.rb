# magic_square.rb
# Magic Square with Odd Number
class OddMagicSquare
  attr_reader :square

  def initialize(n)
    @square = Array.new(n)
    @square.each_index {|i| @square[i] = Array.new(n)}
    middle = n/2
    @square[0][middle] = 1
    @pos = [0,middle]
    @len = n
  end

  def printing_magic_square
    v_border = '+' + '-' * (6 * @len - 1) + '+'
    @square.each do |row|
      puts v_border
      row.each do |r|
        if r then
          print format('|' + "%4d" + ' ', r)
        else
          print '| nil '
        end
      end
      print "|\n"
    end
    puts v_border
  end

  def iterate_square
    value = 2
    last_value = @len ** 2
    while true do
      move
      fill value
      break if value == last_value
      value = value + 1
    end
  end

  private

  def fill(value)
    @square[@pos[0]][@pos[1]] = value
  end

  def move
    move_down if not move_diagonal_up
  end

  def move_diagonal_up
    # get future position
    future_pos = Array.new(2)
    @pos[0] == 0 ? future_pos[0] = @len - 1 : future_pos[0] = @pos[0] - 1
    @pos[1] == @len - 1 ? future_pos[1] = 0 : future_pos[1] = @pos[1] + 1
    # check if it is empty or not
    if @square[future_pos[0]][future_pos[1]] then
      return false
    else
      @pos = future_pos
    end
    return true
  end

  def move_down
    @pos[0] == @len - 1 ? @pos[0] = 0 : @pos[0] = @pos[0] + 1
  end

end
