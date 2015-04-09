class Range

 # Choose the specified number of random elements of the range
 def choose_uniq_members( num = 1 )
   # Make sure the range is large enough to select correct number of uniq members
   raise "RangeBoundaryError" if self.size < num
   return self.to_a if self.size == num

   # Select the specified number of random entries from the range
   tmp = self.dup.to_a
   selected = []
   num.times {  selected << tmp.delete_at( rand( tmp.size )  ) }
   selected.sort
 end

 def size
   @size ||= self.to_a.size
 end

end

class HousieTicket

COLUMNS = [ 1..9, 10..19, 20..29,30..39,40..49,50..59,60..69,70..79,80..90]

def initialize

 # an array of arrays for rows and columns for the final data
 @rows = Array.new(3){ Array.new(9) }

 # Maps out in a 3 x 5 array, which of the final @rows indicies should contain numbers
 row_map = (1..3).inject([]){ |arr, i| arr << (0...COLUMNS.size).choose_uniq_members(5) }

 # Maps the indicies of row_map into column counts so that each column may be populated.
 # The number found for each column will be used to choose from  the relevant range.
 # ie column 0 = 2, therefore two numbers from the range 1..9 should be selected
 the_map = row_map.flatten.inject( Hash.new(0) ){ |col_map, i| col_map[i] += 1; col_map }


 # Populate the final @rows array with the real numbers based on the prototype matrix developed
 # in row_map by choosing the number of uniq values from the columns range as specified in the_map
 (0...9).each do | col_index |
   numbers = COLUMNS[col_index].choose_uniq_members( the_map[col_index] ).reverse
   (0...3).each do | row_index |
     @rows[ row_index ][ col_index ] = numbers.pop if row_map[ row_index ].include?( col_index )
   end
 end
end

# From here down is display methods
# Various display methods to print out the ticket to the terminal
def display
 array = stringify_rows
 print_line_seperator
 array.each do |row|
   puts "|" << row.join( "|" ) << "|"
   print_line_seperator
 end
end

def stringify_rows
 rows = @rows.dup
 rows.map do |row|
   row.map{ |e| if(e) then sprintf(" %02d ", e) else "    " end }
 end
end

def print_line_seperator
 puts "|" << "----|" * 9
end


end

# Runs the program from the terminal
number_of_tickets = ARGV[0]

unless number_of_tickets.to_i > 0
 puts "How many tickets would you like to generate?\n"
 until number_of_tickets.to_i > 0
   number_of_tickets = gets.chomp
 end
end

1.upto(number_of_tickets.to_i ) do |n|
 ticket = HousieTicket.new
 puts "\n\n"
 puts "Ticket #{n}"
 ticket.display
end
