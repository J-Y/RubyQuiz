####

RequiredCounts = [9] + [10] * 7 + [11]
Line = "+----" * 9 + "+\n"  # horizontal line used in text output

# Returns a row pattern for one row of a ticket.  It will be an array
# containing five trues and four falses.  Each true corresponds to a
# number placement and each false a blank.  The positions of the true
# values is random, but weighted by the odds that a number will appear
# in each column.  The first column has the lowest odds (9/18, or 1/2,
# or 50%), the last column the greatest odds (11/18, or 61.1%), and
# the columns in between intermediate odds (10/18, or 5/9, or 55.6%).
def gen_row_pattern
  # copy of RequiredCounts array for relative odds
  relative_odds = RequiredCounts.dup
  total_odds = relative_odds.inject { |sum, v| sum + v }
  row_pattern = Array.new(9, false)
  5.times do
    pick = rand(total_odds)

    # find column for which this random number corresponds
    relative_odds.each_with_index do |o, i|
      pick -= o               # subtract the odds for column from pick
      if pick < 0             # have we reached the indicated column?
        row_pattern[i] = true
        relative_odds[i] = 0  # can't be true again, so odds is now zero
        total_odds -= o       # and total odds have gone down as well
        break
      end
    end
  end

  row_pattern
end

# Returns true if a ticket pattern (an array of three row patterns) is
# valid.  A ticket pattern is valid if every column has at least one
# true in it since a true corresponds to a number.
def valid_ticket_pattern?(ticket_pattern)
  ticket_pattern.transpose.all? { |col| col.any? { |element| element }}
end

# Generates a valid ticket pattern consisting of three row patterns.
def gen_ticket_pattern
  begin
    ticket_pattern = Array.new(3) { gen_row_pattern }
  end until valid_ticket_pattern? ticket_pattern
  ticket_pattern
end

# Returns true only if the book pattern is valid.  A book pattern is
# valid if the numbers in each column either have the correct amount
# (if the book has *all* the ticket patterns) or has the potential to
# have the correct amount (if the book pattern has only a subset of
# the ticket patterns).
def valid_book_pattern?(book_pattern)
  return true if book_pattern.empty?

  tickets_left = 6 - book_pattern.size # how many tickets remain to be placed in book

  # determine how many numbers are in each column of all booklets
  column_counts =
    book_pattern.map { |ticket| ticket.transpose }.transpose.map do |column|
    column.flatten.select { |element| element }.size
  end

  # each of the tickets left to fill in the booklet can have from 1 to 3
  # numbers, so make sure that that will allow us to fill each column with
  # the desired number of numbers
  (0...RequiredCounts.size).all? do |i|
    numbers_left = RequiredCounts[i] - column_counts[i]
    numbers_left >= tickets_left && numbers_left <= 3 * tickets_left
  end
end

# Generate a book pattern recursively by adding one ticket pattern
# after another.  If adding a given ticket pattern makes it so the
# book pattern is invalid, back up and add a different ticket pattern
# in its place (via the catch/throw).
def gen_book_pattern(count, book_pattern)
  throw :invalid_book_pattern unless valid_book_pattern?(book_pattern)
  return book_pattern if count == 0

  # loop until a valid ticket pattern is added to the book pattern
  loop do
    catch(:invalid_book_pattern) do
      return gen_book_pattern(count - 1,
                                   book_pattern + [gen_ticket_pattern])
    end
  end
end

# Returns 9 number "feeders", one per column, for an entire book.
# The numbers in each feeder are appropriate for the column in which
# they are to feed into, and shuffled randomly.
def gen_number_feeders
  feeders = Array.new(9) { Array.new }
  (1..89).each { |i| feeders[i / 10] << i }
  feeders[8] << 90  # add the extra value in the last feeder

  # shuffle the numbers in each feeder
  feeders.each_index { |i| feeders[i] = feeders[i].sort_by { rand } }
end

# Generate a book, which is an array of 6 tickets, where each ticket
# is an array of three rows, where each row is an array containing
# nine values, five of which are numbers and four of which are nils.
def gen_book
  book_pattern = gen_book_pattern(6, [])
  feeders = gen_number_feeders

  book_pattern.map do |ticket_pattern|
    # determine how many numbers will be consumed in each column of
    # ticket
    nums_in_cols = ticket_pattern.transpose.map do |col|
      col.select { |v| v }.size
    end

    # sort the consumed numbers in the feeders, so the columns will be
    # sorted
    feeders.each_index do |i|
      feeders[i] = feeders[i][0...nums_in_cols[i]].sort +
        feeders[i][nums_in_cols[i]..-1]
    end

    # convert the trues in each column into numbers by pulling them
    # from the feeder corresponding to the column
    ticket_pattern.map do |row|
      new_row = []
      row.each_index { |i| new_row << (row[i] ? feeders[i].shift : nil) }
      new_row
    end
  end
end

# Convert a book into a large string.
def book_to_s(book)
  book.map do |ticket|
    Line + ticket.map do |row|
      "|" + row.map { |v| " %2s " % v.to_s }.join("|") + "|\n"
    end.join(Line) + Line
  end.join("\n")
end

# If run from the command-line, produce the output for one book.
if __FILE__ == $0
  puts book_to_s(gen_book)
end
