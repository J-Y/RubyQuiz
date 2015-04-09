class Housie

  def initialize
    @colset = Array.new(9) { [] }
    @numbers = 0
  end

  # Push a number to this ticket.
  #
  # If this number can't fit with the numbers already in this housie, we return
  # one of the old numbers in the housie that we removed to make this number fit.
  #
  def push(number)
    raise "Tried to push to generated housie ticket" if @housie
    column = number == 90 ? 8 : number / 10
    @colset[column] << number
    if @colset[column].size == 4
      @colset[column].shift
    elsif @numbers == 15
      random_col = rand(9) while random_col.nil? || @colset[random_col].size < 2
      @colset[random_col].shift
    else
      @numbers += 1
      nil
    end
  end

  # Generates a ticket from added data
  # Since we have 15 numbers, not more than 3 of each column type we know we
  # can create a ticket, but we want a randomized look to it.
  def generate
    raise "Not enough data to generate ticket" unless complete?
    @housie = Array.new(3) { Array.new(9) }
    (0..8).sort_by { rand }.each do |column|
      @colset[column].size.times do
        rows = @housie.sort_by { rand }.sort { |row1, row2| row1.compact.size <=> row2.compact.size }
        rows.shift until rows.first[column].nil?
        rows.first[column] = true
      end
    end
    9.times do |column|
      @colset[column].sort!
      @housie.each { |row| row[column] = @colset[column].shift if row[column] }
    end
    self
  end

  # Ugly code to display a ticket.
  def to_s
    return "Not valid" unless @housie
    @housie.inject("") do |sum, row|
      sum + "+----" * 9 + "+\n" +
      row.inject("|") { | sum, entry | sum + " #{"%2s" % entry} |" } + "\n"
    end +
    "+----" * 9 + "+"
  end

  def complete?
    @numbers == 15
  end

  def Housie.new_book
    housies = Array.new(6) { Housie.new }
    numbers = Array.new(9) { |col| Array.new(10) { |i| i + col * 10 } }
    numbers[0].delete 0
    numbers[8] << 90
    # First make sure every book has at least one entry
    numbers.each do |col|
      col.replace col.sort_by { rand }
      housies.each { |housie| housie.push(col.shift) }
    end
    # That done, distribute the rest of the numbers
    numbers.flatten!
    while numbers.size > 0 do
      pushed_out = housies[rand(6)].push(numbers.shift)
      numbers << pushed_out if pushed_out
    end
    housies.collect { |housie| housie.generate }
  end

  def Housie.new_ticket
    housie = Housie.new
    numbers = Array.new(9) { |col| Array.new(10) { |i| i + col * 10 } }
    numbers[0].delete 0
    numbers[8] << 90
    # First make sure this ticket has at least one entry
    numbers.each do |col|
      col.replace col.sort_by { rand }
      housie.push(col.shift)
    end
    # Distribute the rest of the numbers
    numbers = numbers.flatten!.sort_by { rand }
    until housie.complete?
      returned = housie.push numbers.shift
      numbers << returned if returned
    end
    housie.generate
  end

end


puts "A book of tickets:"
Housie.new_book.each_with_index { |housie, index| puts "Ticket #{index + 1}"; puts housie.to_s }

puts "A single ticket:"
puts Housie.new_ticket.to_s
