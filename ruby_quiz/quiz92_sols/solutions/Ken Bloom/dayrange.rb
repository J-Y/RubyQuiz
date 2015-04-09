class DayRange
   NAMEMAP={"Mon"=>1, "Tue"=>2, "Wed"=>3, "Thu"=>4, "Fri"=>5, "Sat"=>6, 
   "Sun"=>7, "Thurs"=>4, "Monday"=>1, "Tuesday"=>2, "Wednesday"=>3, 
   "Thursday"=>4, "Friday"=>5, "Saturday"=>6, "Sunday"=>7}

   REVERSENAMEMAP=[nil, "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

   def initialize(*args)
      #parse arguments into Integers from 1 to 7
      args.collect!{|x| NAMEMAP[x] || x}
      args.sort!.uniq!
      raise ArgumentError if args.any? do |x|
	 not x.is_a?(Fixnum) or not (1..7).include?  x
      end

      #turn everything into ranges
      @ranges=args.inject([]) do |a,v|
	if a[-1]==nil or a[-1].last != v-1
	  a << (v..v)
	else
          #extend the existing range to include the new element
	  a[-1]=((a[-1].first)..v)
	end
	a
      end

      #this code can be included if you would like wrap-around ranges
      #note that it constructs an ranges (with last<first) which doesn't
      #actually work with some ruby features. Hence, I don't use those
      #features which it breaks.

      #if @ranges[-1].last==7 and @ranges[0].first==1
      #   v=((@ranges[-1].first)..(@ranges[0].last))
      #   @ranges.delete_at(-1)
      #   @ranges.delete_at(0)
      #   @ranges << v
      #end
   end

   def to_s
      #determine how to print each range based on the length of the range
      @ranges.collect do |r|
	 if r.first==r.last
	    REVERSENAMEMAP[r]
	 elsif r.first==r.last-1
	    "#{REVERSENAMEMAP[r.first]}, #{REVERSENAMEMAP[r.last]}"
	 else
	    "#{REVERSENAMEMAP[r.first]}-#{REVERSENAMEMAP[r.last]}"
	 end
      end.join(", ")
   end
end

puts DayRange.new(1,2,3,4,5,6,7).to_s
puts DayRange.new(1,2,3,6,7).to_s
puts DayRange.new(1,3,4,5,6).to_s
puts DayRange.new(2,3,4,6,7).to_s
puts DayRange.new(1,3,4,6,7).to_s
puts DayRange.new(7).to_s
puts DayRange.new(1,7).to_s
puts DayRange.new(1,8).to_s rescue puts "ArgumentError"
