class TicketGenerator
 def init_bins
   # Create and fill the 9 bins of numbers, corresponding to
   # the allowed numbers for each column.
   @bins = Array.new
   # 1 through 9
   @bins << (1..9).sort_by{ rand }
   # 10 through 19, 20 through 29, etc.
   10.step(70, 10) do |x|
     @bins << (x..x+9).sort_by{ rand }
   end
   # 80 through 90
   @bins << (80..90).sort_by{ rand }
 end
 def retrieve_row
   # Create a row by pulling one number from each of five non-empty bins.
   row = Array.new(9, nil)
   # Randomize which bins to choose from, but favor the most filled bins --
   # so we don't end up with less than 5 non-empty bins with still more rows to create.
   bin_index_array = (0...@bins.length).sort_by{ rand }.sort_by{ |b| @bins[b].length }
   5.times do
     bin_index = bin_index_array.pop
     row[bin_index] = @bins[bin_index].pop
   end
   row
 end
 def build_book
   # Generate 18 rows and divide them between six tickets
   init_bins
   all_rows = Array.new(18){ retrieve_row }
   tickets = Array.new
   0.step(15, 3) do |x|
     ticket = Ticket.new(all_rows[x...x+3].sort_by { rand })
     tickets.push(ticket)
     # If an invalid ticket is found, indicate failure
     # by setting the return value to false.
     if not ticket.is_valid?
       tickets = false; break
     end
   end
   tickets
 end
 def print_book
   # Keep generating ticket books until a valid
   # one is returned.  Then, print out the tickets.
   book = build_book until book
   book.each { |t| t.print_ticket; puts "\n"}
 end
 private :init_bins, :retrieve_row, :build_book
 public :print_book
end

class Ticket
 def initialize(rows)
   # A ticket consists of an array of three rows,
   # with 5 numbers and 4 nil entries per row.
   @rows = rows
   @empty_column = false
   validate_ticket
 end
 def is_valid?
   not @empty_column
 end
 def validate_ticket
   # Convert three rows of 9 numbers into 9 columns of three numbers,
   # check that each column satisfies the ascending order constraint,
   # and then convert back into rows.
   columns = Array.new(9) { [] }
   columns.each { |c| @rows.each { |r| c << r.shift }; rectify(c) }
   @rows.each { |r| columns.each { |c| r << c.shift } }
 end
 def rectify(column)
   # If there are 2 or 3 numbers in a column, they must
   # appear in increasing order downward.  If they don't, then
   # swap the numbers around while maintaining 5 numbers
   # in each row.
   case column.nitems
     when 0 then @empty_column = true
     when 1 then column # do nothing
     when 2
       nil_index = column.index(nil)
       non_nils = [0,1,2] - [nil_index]
       first_nn, last_nn = non_nils.first, non_nils.last
       # Swap the two non-nil elements
       if column[first_nn] > column[last_nn]
         column[first_nn], column[last_nn] = column[last_nn], column[first_nn]
       end
     when 3 then column.sort! # just sort the three numbers
   end
 end
 def print_ticket
   puts "+----" * 9 + "+"
   @rows.each do |row|
     line = row.inject("|") do |str, x|
       if not x
         str + "    |"
       elsif x < 10
         str + "  #{x} |"
       else
         str + " #{x} |"
       end
     end
     puts line
     puts "+----" * 9 + "+"
   end
 end
 private :validate_ticket, :rectify
 public :print_ticket, :is_valid?
end
TicketGenerator.new.print_book
