class Sudoku
  attr_reader :solutions

  def initialize( input )
    @cells = Array.new(81)
    @possibilities = {}
    @solutions = 0
    index = 0
    input.to_s.scan(/./) do |c|
      case c
        when '1'..'9' : @possibilities[index] = [ @cells[index] = c.to_i ]
        when '_'      : @possibilities[index] = (1..9).to_a 
        else next
      end
      break if (index += 1) == 81
    end
    # raise "Input data incomplete" if index != 81
  end

  def solve
    return false unless reduce_possibilities(@possibilities)
    return _solve(@possibilities)
  end

  # to_s borrow from Simon ...
  def to_s
    "+-------+-------+-------+\n| " +
    Array.new(3) do |br|
      Array.new(3) do |r|
        Array.new(3) do |bc|
          Array.new(3) do |c|
            @cells[br*27 + r * 9 + bc * 3 + c] || "_"
          end.join(" ")
        end.join(" | ")
      end.join(" |\n| ")
    end.join(" |\n+-------+-------+-------+\n| ") +
    " |\n+-------+-------+-------+\n"
  end 

  private

  # The cell's neighborhoods are cells need to check to be sure no duplicate
  # value with the cell. It has exactly 20 cells neighborhoods per cell.
  NEIGHBORHOODS = Array.new(81) do |index| 
    row, col = index / 9, index % 9
    r, c = row / 3 * 3, col / 3 * 3
    ary = []
    9.times do |i| 
      ary << (i * 9 + col)               # add cells at the same column 
      ary << (row * 9 + i)               # add cells at the same row
      ary << ((i/3) + r) * 9 + (i%3) + c # add cells at the same 3x3 box
    end
    ary.uniq - [index]
  end

  def reduce_possibilities(possibilities)
    index = number = nil
    while possibilities.find { |index, number| number.size == 1 }
      @cells[index] = number[0]
      possibilities.delete(index)
      neighborhoods = NEIGHBORHOODS[index]
      possibilities.each do |key, value|
        next unless neighborhoods.include?(key)
        value -= number
        if value.size == 0
          return false
        else
          possibilities[key] = value
        end
      end
    end
    true
  end

  def _solve(possibilities)
    return true if possibilities.empty?
    key, values = possibilities.shift    
    values.each do |v|
      pos = possibilities.dup
      pos[key] = [v]
      next unless reduce_possibilities(pos)
      return true if _solve(pos)
    end
    false
  end

end


if __FILE__ == $0
  input = ''
  while line = gets
    input << line
  end

  sudoku = Sudoku.new(input)
  puts sudoku.solve ? sudoku : "This puzzle has no solution!"
end
