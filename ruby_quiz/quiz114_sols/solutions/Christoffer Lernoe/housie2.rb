class Housie

  def initialize(housie_array)
    @housie_array = housie_array
    raise "Illegal size" unless @housie_array.size == 3
    @housie_array.each { |row| raise "Illegal row in housie #{row.inspect}" unless row.compact.size == 5 }
    9.times do |col|
      raise "Illegal column #{col}" unless @housie_array.collect { |row| row[col] }.compact.size > 0
    end
  end

  # Ugly code to display a ticket.
  def to_s
    @housie_array.inject("") do |sum, row|
      sum + "+----" * 9 + "+\n" +
      row.inject("|") { | sum, entry | sum + " #{"%2s" % entry} |" } + "\n"
    end +
    "+----" * 9 + "+"
  end

  def Housie.new_book
    housies = Array.new(6) { Array.new(3) { Array.new(9) } }
    columns = Array.new(9) { |col| Array.new(10, col)  }
    columns[0].shift
    columns[8] << 8

    # First make sure every book has at least one entry.
    # These entires are fixed and can't be swapped out.
    columns.each do |col|
      housies.each do |housie|
        housie.select { |row| row.compact.size < 5 }.sort_by { rand }.first[col.shift] = :fixed
      end
    end

    # Merge all rows
    all_rows = []
    housies.each { |housie| housie.each { |row| all_rows << row } }

    # Fill all rows, start with the one with fewest entries, resolve ties randomly
    while (columns.flatten.compact.size > 0) do
       columns.select { |col| col.size > 0 }.each do |col|
         all_rows.reject { |row| row[col.first] }.sort_by { rand }.each do |row|
           break unless col.first
           # A full row needs to have a value swapped out
           if row.compact.size == 5
             # Only try to swap if we have swappable entries
             if row.member? :selected
               removed_col = rand(9) while removed_col.nil? || row[removed_col] != :selected;
               row[removed_col] = nil
               columns[removed_col] << removed_col
               row[col.shift] = :selected
             end
           else
             row[col.shift] = :selected
           end
         end
      end
    end

    # Populate actual numbers
    values = Array.new(9) { |col| Array.new(10) { |i| i + col * 10 } }
    values[0].shift # remove 0
    values[8] << 90 # add 90

    values.each_with_index do |col, index|
      col = col.sort_by { rand }
      housies.each do |housie|
        entries = housie.inject(0) { |sum, row| sum + (row[index] ? 1 : 0) }
        values = col.slice!(0...entries).sort
        housie.each { |row| row[index] = values.shift if row[index] }
      end
    end

    housies.collect { |housie| Housie.new(housie) }
  end

end
