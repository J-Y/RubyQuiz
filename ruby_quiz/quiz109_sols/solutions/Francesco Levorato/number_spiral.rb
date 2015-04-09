#! /usr/bin/env ruby
#
# Francesco Levorato aka flevour   <flevour ^a-t^ gmaildotcom>
# Sunday, 14 January 2007
# Solution for Ruby Quiz number 109 - Number Spiral

class Array
  def decrease_all
    self.map! { |x| x = x - 1}
  end
  def increase_all
    self.map! { |x| x = x + 1}
  end
  def enqueue(x)
    self.insert(0, x)
  end

  # sort of a hackish method to remove unwanted numbers from @left and @right
  # i haven't figured out a valid reason to explain why i need to remove these values
  # but otherwise things won't work and I haven't time to think more on the topic
  def delete_invalid
    self.map! {|x| (x > 1) ? x : nil}
    self.compact!
  end
end

class NumberSpiral
  # this solution addresses clockwise from center to outside filling method
  # my approach is based on the observation that each row of the matrix is composed
  # of 3 parts: 0 or more columns, a series of consecutive numbers, 0
or more columns
  def initialize(n, direction = :ck)
    @n = n
    @dim = @n*@n
    # left contains the first part of a row
    # right contains the third part of a row
    # in a 8x8: if the row is 54,29,12,13,14,15,16,37
    # left: [54, 29], right: [37]
    @left = []
    @right = []
    # just wanted to try out this block thingie Ruby is so famous about
    @format = Proc.new { |x| print sprintf("%3s", x.to_s + " ") }
    @direction = direction # :ck or :cck
  end

  # the 3 following methods, h,l,d are were the funniest part of the quiz: finding
  # the relationships intercurring between special elements of the spiral.
  # they are used to build only the first (N/2 + 1) rows, as the other ones are
  # built according only to the data structures @left and @right

  # to explain these 3 methods, define the following function
  # pivot(row): returns the number at given row just before the start of the second part
  #             of the row (the part containing the consecutive numbers)

  # given a row number
  # returns the distance from the pivot to the first "spiral wall" below it
  # subtracts 1 not to overlap with l(x) results
  # in a 8x8: given row 7 returns length from 54 down to 50
  def h(x)
    2*x - @n - 1
  end

  # given a row number
  # returns the width of the next horizontal segment going from pivot toward
  # the center of the spiral
  # in a 8x8: given row 6 returns length from 25 to 20
  def l(x)
    2 * ( x + 1 ) - @n
  end

  # given a row number, returns the difference between the pivot and the number
  # just at its right
  # in a 8x8: given 7 returns the difference between 55 and 30
  def d(x)
    2 * ( l(x) + h(x) ) - 1
  end

  def print_me
    row = @n
    start = @dim - @n
    # prints first row
    print_row(consecutive_numbers(start))
    print "\n"

    # prepare for loop
    pivot = start - 1
    @left << pivot

    # prints the top rows, it stops after printing the row containing the zero
    while(pivot >= 0) do
      row = row - 1
      pivot = pivot - d(row)

      # gets middle consecutive numbers
      middle = consecutive_numbers(pivot)
      print_row(middle)

      @left << pivot
      @left.decrease_all

      @right.enqueue(middle.last) # last number of consecutive series will be in the right part in next iteration
      @right.increase_all

      pivot = @left.last
      print "\n"
    end

    @left.delete_invalid
    @right.delete_invalid
    row = row -1

    # prints the remainder of the spiral
    while(row > 0) do
      from= @left.pop

      middle = consecutive_numbers(from, :down)
      last_printed = middle.last
      print_row(middle)

      @right.delete_at(0)

      @left.decrease_all
      @right.increase_all
      row = row - 1
      print "\n"
    end
  end

  def consecutive_numbers(n, go = :up)
    array = []
    (@n - @left.size - @right.size).times do
      array << n
      if go == :up
        n = n + 1
      else # go == :down
        n = n - 1
      end
    end
    array
  end

  def print_row(middle)
    if @direction == :ck
      (@left + middle + @right).each(&@format)
    else
      (@left + middle + @right).reverse.each(&@format)
    end
  end
end

if ARGV[0]
  NumberSpiral.new(ARGV[0].to_i).print_me
else
  puts "Call me: #{$0} <matrix_dim>\n"
end
