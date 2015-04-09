#First of all, let's look at the books.
#Assuming a symetrical distribution of tens, we have that for all nine rows,
#tickets can have one of the following distributions of numbers in a columnn:
def make_poss
  [  [1, 1, 1, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 2, 2, 2, 2, 3],
    [1, 1, 1, 1, 1, 2, 2, 3, 3],
    [1, 1, 1, 1, 1, 1, 3, 3, 3]  ]
end

#Don't forget to put the numbers in the bag!
def make_container
  initial = (0..8).to_a.collect{|n| ((10*n)..(10*(n+1) - 1)).to_a }
  initial[0].delete(0); initial[-1].push(90)
  initial
end

class Array
  #Tricked so it adds only the non-nil elements
  def sum
    inject(0) {|sum, n| n.nil? ? sum : sum + n }
  end

  def column(n)
    collect{|row| row[n]}
  end
end

class Book < Array

  attr_accessor :tickets, :distribution

  def initialize
    #Lets's the fun begin. As stated before, a ticket can have on of 4 possible
    #distribution of tickets (and they are ALL the possibilities).
    #So, we start defining randomly the distributions of our tickets.
    #Furthermore, we scramble the possibilities, so any row can have any distribution provided.
    super(Array.new(6).collect{|i| (poss = make_poss)[rand(poss.size)].sort_by{rand} })

    #Now we have to distribute our matrix. Because of the above, each row sums 15, but we have to make
    #each column sum 10.
    make_distribution

    #Now we adjust the numbers on each ten.
    balance
    @tickets = []

    #And we're ready
    make_tickets
  end

  #This method iterates each column, and accomodate the numbers until the sum of each column is 10.
  def make_distribution
    for i in 0...9
      s = column(i).sum
      remaining = (10 - s).abs
      if s != 10
      #If the sum is different than 10, decrement one to the greater
      #and increment it to the possible in the row, or viceversa.
      #If that's not possible, go onto the next row, and repeat if necessary.
        remaining.times do
          index = 0
          until gain(index, i, (s < 10 ? 1 : -1))
            index += 1
            index = 0 if index == 5
          end
        end
      end
    end
  end

  def display
    @tickets.each {|ticket| ticket.display}
  end

  #Knowing the distribution of the tickets, they are done almost automatically.
  def make_tickets
    container = make_container
    each{ |row|  @tickets << Ticket.new(row, container) }
  end

  #Returns the index where the increment occured, or nil if cannot be done
  def gain(row, column, num = 1)
    item = self[row][column]

    #We know a priori that the numbers must be between 1 and 3
    return nil if (item == 3 && num == 1) or (item == 1 && num == -1)

    #iterate over the array, starting from the right of the column
    for i in (column + 1)...(self[row].size)

      #Find the first element that can accept a loss of -num (or a gain)
      if (1..3) === (self[row][i] - num)
        #if so, increment and decrement the numbers.
        self[row][column] += num
        self[row][i] -= num
        return i
      end
    end
    return nil
  end

  #Balances the ticket distribution so the first row has 9 numbers and
  #the last one 11, without affecting the sum.
  def balance
    for row in self
      if row[0] > 1 and row[-1] < 3
        row[0] -= 1
        row[-1] += 1
        break
      end
    end
  end

end


class Ticket < Array

  def initialize(distribution = (poss = make_poss)[rand(poss.size)], container = make_container)
    #When initializing, we first make the ticket 'vertical' so its easier to keep track of the
    #numbers in each row.
    super(9); collect! {|row| []}
    distribution.each_with_index do |distr, index|
      choose = container[index]
      distr.times do
        #Exhausting possibilities
        self[index] << choose.slice!(rand(choose.size))
      end
    end
    collect! { |row| row.sort! }
    make_format
  end

  def make_format
    #Iterate over the colums
    for i in 0...3
      #Do this until we have 5 elements per column.
      until (s = column(i).compact.length) == 5
        #If the number of elements in the column is more than 5,
        #move one randomly to the next place
        if s > 5
          x = rand(9)
          self[x].insert(i, nil) unless self[x].length == 3
        else
        #If the number is less than four (that can only happen in the second column),
        #remove one nil
          for row in self
            if row[1] == nil and row[2] != nil
              row[1], row[2] = row[2], nil
              break
            end
          end
        end
      end
    end
    #Now we just transpose the ticket.
    replace((0...3).collect{ |i| column(i) })
  end

  def display
    print(top = "+----" * 9 + "+\n")
    each do |row|
      row.each{ |number|  print("|" + " " * (3 - number.to_s.length) + number.to_s + " ") }
      print "|\n", top
    end
    puts
  end

end

puts "Type B for a complete book, or T for a single ticket.\nType anything else to exit"
while (option = gets.chomp) =~ /\A[BbTt]/
  if option =~ /\A[Bb]/
    #Now all we have to do is to create a new book...
    book = Book.new
    #and display it...
    puts "BINGO!\n"
    book.display
  else
    #Or we can make single tickets... for cheating... you know
    puts "Today's my lucky day"
    x = Ticket.new
    x.display
  end
  puts "Play again?"
end
