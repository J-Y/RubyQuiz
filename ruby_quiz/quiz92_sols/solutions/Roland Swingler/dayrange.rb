require 'parsedate'

class DayRange
 WEEK = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

 def initialize(*days)
   @start = 0
   @days = Array.new(7, nil)
   days.each do |day|
     i = int_for day
     @days[i] = WEEK[i]
   end
 end

 def to_s
   # Convert any middle days to "-"
   output = [@days[0]] + (1..6).map do |i|
     (@days[i] &&
      (WEEK.include?(@days[i-1]) || @days[i-1] == "-") &&
      WEEK.include?(@days[i+1]) &&
      "-") || @days[i]
   end
   # remove nils, duplicate dashes and any commas surounding them
   output.compact.join(", ").gsub(/(, )?-, /, '-').squeeze
 end

 def start=(day)
   i = int_for(day) - @start
   if i != 0
     @start += i
     # shift days from the front or back of the array to the other
end
     # so as to get the start day to index 0
     index, shift_len = (i > 0) ? [0, i] : [i, -i]
     mv_days = @days.slice!(index, shift_len)
     @days = (i > 0) ? @days + mv_days : mv_days + @days
   end
 end

 def start
   WEEK[@start]
 end

 private

 def int_for(day)
   # Get the day as an integer regardless of input
   i = ((day.is_a?(String) && ParseDate.parsedate(day)[7]) || day) - 1
   # ParseDate thinks that Sunday is the 0th day of the week
   i = 6 if -1 == i
   raise ArgumentError unless (0..6).include?(i)
   i
 end
end
