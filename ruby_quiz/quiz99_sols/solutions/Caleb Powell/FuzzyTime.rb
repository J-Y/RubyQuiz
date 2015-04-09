class FuzzyTime
    
    attr_accessor(:time, :fuzzy_time)
    
    def initialize(current_time=Time.now, deviation=300)
		@time = current_time
		@fuzzy_time = current_time
		@deviation = deviation
	end

	def to_s
		@fuzzy_time = random_time(@time, @fuzzy_time, @deviation)
		s = @fuzzy_time.strftime("%I:%M")
		s.gsub!(/([\d][\d]:[\d])[\d]/) { |s| $1+"~"}
	end

	def actual
		Time.now
	end

	def advance(seconds)
		@time = time + seconds
	end

	def update
		@time = Time.now
	end

     
    # Compares two Time objects in a fuzzy manner. To be equal, they must have
    # the same values for the year, month, day, and hour. Their minute
    # values need to fall into the same 10-digit range.
    # For example: 
    # fuzzy_compare(2006/01/01 01:15:52,2006/01/01 01:16:41)
    # =>0  
    # fuzzy_compare(2006/01/01 01:15:52,2006/01/01 01:21:41)
    # =>-1  
    # fuzzy_compare(2006/01/01 01:15:52,2006/01/01 01:09:41)
    # =>1  
    def fuzzy_compare(time1, time2)
        if(time1 < time2 &&
            (time1.year < time2.year || 
            time1.month < time2.month ||
            time1.day < time2.day ||
            time1.hour < time2.hour || 
            ((time1.min + 10) / 10).floor < ((time2.min+10) / 10).floor))
            return -1
        elsif(time1 > time2 &&
            (time1.year > time2.year || 
            time1.month > time2.month ||
            time1.day > time2.day ||
            time1.hour > time2.hour || 
            (time1.min / 10).floor > (time2.min / 10).floor))           
            return 1 
        else
            return 0 
        end
    end
    
    #generates a random time object based on the current_time
    def random_time(time, min_time_boundary, secs=60)
        random_secs = random(secs)
        new_fuzzy_time = nil
        if(subtract_time?)  
            new_fuzzy_time = time-random_secs
        else
            new_fuzzy_time = time+random_secs
        end
        if (fuzzy_compare(new_fuzzy_time, min_time_boundary) == -1)
            new_fuzzy_time = min_time_boundary.succ # add the time back
        end    
        new_fuzzy_time  
    end  
    
    #the following methods facilitate unittesting
    def subtract_time?
        (rand(10) % 2) == 1
    end      
    
    def random(seconds)
        rand(seconds)
    end
end


