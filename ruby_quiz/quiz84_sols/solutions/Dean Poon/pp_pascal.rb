class Pascal
  class << self
    # Entry of Pascal's Triangle (numbering rows and columns starting
    # from zero).
    def entry(row, col)
      @entry ||= []
      @entry[row] ||= [1]       # Base case: entry(any_row, 0) => 1

      if 2 * col > row          # Take advantage of symmetry
        entry(row, row - col)
      else                      # Recurse with memoization
        @entry[row][col] ||= entry(row - 1, col - 1) + entry(row - 1, col)
      end
    end
  end

  attr_accessor :rows

  def initialize(rows)
    self.rows = rows
  end

  def to_s
    # Make each entry wide enough for the largest number and its padding
    max_entry = Pascal.entry(rows - 1, (rows - 1) / 2)
    entry_width = 2 + max_entry.to_s.length
    line_width = rows * entry_width

    (0...rows).collect do |row|
      (0..row).collect do |col|
        Pascal.entry(row, col).to_s.center(entry_width)
      end.join.center(line_width)
    end.join("\n")
  end
end

puts Pascal.new(ARGV[0].to_i)
