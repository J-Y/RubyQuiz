#DayRange
#
#DayRange accepts an array of day IDs (Mon = 1, Tue =
2, etc.)
#and returns a formatted string of the days, using day
ranges
#where appropriate, e.g, "Mon-Wed, Fri"
#
#author: Bryan Donovan

class DayRange

 def day_hash
   { '1'=>'Mon',
     '2'=>'Tue',
     '3'=>'Wed',
     '4'=>'Thu',
     '5'=>'Fri',
     '6'=>'Sat',
     '7'=>'Sun' }
 end

 def initialize(day_ids)
   @day_ids = day_ids.uniq.sort
   unless @day_ids.all? { |d| d.between?(1,7) }
     raise ArgumentError "Days must be between 1 and 7"
   end

 end

 #Returns formatted string representing the day array
 def to_s
   day_abbrs = day_hash
   i = 0
   #Array of consec_days arrays
   consec_day_groups = []
   #Array of consecutive days.  This gets
   #reset when we find a day that is not
   #part of a consecutive set of days.
   consec_days = []

   @day_ids.each do |day_id|
     if i == 0
       #add the day abbr for this day if this is the first
       #element of @day_ids.
       consec_days << day_abbrs[day_id.to_s]

     elsif @day_ids[i-1] == (day_id - 1)
       #if this is not the first day in @day_ids, check
       #if the previous day in the array is the real life
       #previous day of the week.  If so, add it to the
       #consec_days array
       consec_days << day_abbrs[day_id.to_s]
     else
       #otherwise start a new consec_days array and
       #add the current consec_days array to the
       #consec_day_groups array.
       consec_day_groups << consec_days

       consec_days = []
       consec_days << day_abbrs[day_id.to_s]
     end
     #Always add the consec_days array when this is the
     #last day of the @day_ids array
     if day_id == @day_ids.last
       consec_day_groups << consec_days
     end
     i += 1
   end

   day_strings = []
   consec_day_groups.each do |c|
     if c.length > 2
       day_strings <<  c.first.to_s + "-" + c.last.to_s
     else
       day_strings << c.join(", ")
     end
   end
   return day_strings.join(", ")
 end

end
