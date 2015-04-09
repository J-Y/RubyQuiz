require 'mathn'

CompactOutput = false

# calculate the least common multiple of one or more numbers
def lcm(first, *rest)
  rest.inject(first) { |l, n| l.lcm(n) }
end

# Returns nil if there is no solution or an array containing two
# elements, one for the left side of the equation and one for the
# right side.  Each of those elements is itself an array containing
# pairs, where each pair is an array in which the first element is the
# number of times that word appears and the second element is the
# word.
def solve_to_array(words)
  # clean up word list by eliminating non-letters, converting to lower
  # case, and removing duplicate words
  words.map! { |word| word.downcase.gsub(/[^a-z]/, '') }.uniq!

  # calculate the letters used in the set of words
  letters = Hash.new
  words.each do |word|
    word.split('').each { |letter| letters[letter] = true }
  end

  # create a matrix to represent a set of linear equations.
  column_count = words.size
  row_count = letters.size
  equations = []
  letters.keys.each do |letter|
    letter_counts = []
    words.each { |word| letter_counts << word.count(letter) }
    equations << letter_counts
  end

  # transform matrix into row echelon form
  equations.size.times do |row|
    # re-order the rows, so the row with a value in then next column
    # to process is above those that contain zeroes
    equations.sort! do |row1, row2|
      column = 0
      column += 1 until column == column_count ||
        row2[column].abs != row1[column].abs
      if column == column_count : 0
      else row2[column].abs <=> row1[column].abs
      end
    end

    # figure out which column to work on
    column = (0...column_count).detect { |i| equations[row][i] != 0 }
    break unless column

    # transform rows below the current row so that there is a zero in
    # the column being worked on
    ((row + 1)...equations.size).each do |row2|
      factor = -equations[row2][column] / equations[row][column]
      (column...column_count).each do |c|
        equations[row2][c] += factor * equations[row][c]
      end
    end
  end

  # only one of the free variables chosen randomly will get a 1, the
  # rest 0
  rank = equations.select { |row| row.any? { |v| v != 0 }}.size
  free = equations[0].size - rank
  free_values = Array.new(free, 0)
  free_values[rand(free)] = 2 * rand(2) - 1

  values = Array.new(equations[0].size)  # holds the word_counts

  # use backward elimination to find values for the variables; process
  # each row in reverse order
  equations.reverse_each do |row|
    # determine number of free variables for the given row
    free_variables = (0...column_count).inject(0) do |sum, index|
      row[index] != 0 && values[index].nil? ? sum + 1 : sum
    end

    # on this row, 1 free variable will be calculated, the others will
    # get the predetermined free values; the one being calculated is
    # marked with nil
    free_values.insert(rand(free_variables), nil) if free_variables > 0

    # assign values to the variables
    sum = 0
    calc_index = nil
    row.each_index do |index|
      if row[index] != 0
        if values[index].nil?
          values[index] = free_values.shift

          # determine if this is a calculated or given free value
          if values[index] : sum += values[index] * row[index]
          else calc_index = index
          end
        else
          sum += values[index] * row[index]
        end
      end
    end
    # calculate the remaining value on the row
    values[calc_index] = -sum / row[calc_index] if calc_index
  end

  if values.all? { |v| v } && values.any? { |v| v != 0 }
    # in case we ended up with any non-integer values, multiply all
    # values by their collective least common multiple of the
    # denominators
    multiplier =
      lcm(*values.map { |v| v.kind_of?(Rational) ? v.denominator : 1 })
    values.map! { |v| v * multiplier }

    # deivide the terms into each side of the equation depending on
    # whether the value is positive or negative
    left, right = [], []
    values.each_index do |i|
      if values[i] > 0 : left << [values[i], words[i]]
      elsif values[i] < 0 : right << [-values[i], words[i]]
      end
    end

    [left, right]   # return found equation
  else
    nil  # return no found equation
  end
end


# Returns a string containing a solution if one exists; otherwise
# returns nil.  The returned string can be in either compact or
# non-compact form depending on the CompactOutput boolean constant.
def solve_to_string(words)
  result = solve_to_array(words)
  if result
    if CompactOutput
      result.map do |side|
        side.map { |term| "#{term[0]}*\"#{term[1]}\"" }.join(' + ')
      end.join(" == ")
    else
      result.map do |side|
        side.map { |term| (["\"#{term[1]}\""] * term[0]).join(' + ') }.
          join(' + ')
      end.join(" == ")
    end
  else
    nil
  end
end


if __FILE__ == $0  # if run from the command line...
  # collect words from STDIN
  words = []
  while line = gets
    words << line.chomp
  end

  result = solve_to_string(words)

  if result : puts result
  else exit 1
  end
end
