=begin
Justin Ethier
October 2007
Solution to Ruby Quiz 144 - Time Window

Problem Statement:
Write a Ruby class which can tell you whether the current time (or any given time) is within a particular "time window".
Time windows are defined by strings in the following format:

# 0700-0900 # every day between these times
# Sat Sun # all day Sat and Sun, no other times
# Sat Sun 0700-0900 # 0700-0900 on Sat and Sun only
# Mon-Fri 0700-0900 # 0700-0900 on Monday to Friday only
# Mon-Fri 0700-0900; Sat Sun # ditto plus all day Sat and Sun
# Fri-Mon 0700-0900 # 0700-0900 on Fri Sat Sun Mon
# Sat 0700-0800; Sun 0800-0900 # 0700-0800 on Sat, plus 0800-0900 on Sun

Time ranges should exclude the upper bound, i.e. 0700-0900 is 07:00:00 to 08:59:59. 
An empty time window means "all times everyday".
=end

# Class to store a single time range defined by a start/end
class TimeRange
  # Each Input in form of "HHMM"
  def initialize(start_str, end_str)
    @start = start_str.to_i 
    @end = end_str.to_i
  end
  
  attr_reader :start, :end
end

# Represents a single time period for particular days and times
# A time window may contain several of these frames
class TimeFrame
  # Days - Bitmask of 7 fields (Sun @ 0, Mon @ 1, Tues @ 2, etc)
  # Time range - List of start/end time ranges defining the time frame
  def initialize(days, time_ranges)
    @days = days
    @time_ranges = time_ranges
  end
  
  # Does the given Time match this Time Frame?
  def include?(time)
    if @days[time.wday]
      # If no times then days matching is good enough 
      return true if @time_ranges.size == 0
      
      # Check time range(s)
      for time_range in @time_ranges
        time_n = time.hour * 100 + time.min
        return true if time_n >= time_range.start and
                       time_n <  time_range.end
      end
    end
    
    false
  end
end

# Defines a time window spanning multiple days and time ranges
class TimeWindow
  Days = ["Sun", "Mon", "Tues", "Wed", "Thu", "Fri", "Sat"]

  # Constructor accepting a string as defined in ruby quiz description
  def initialize(time_window)
    @timeframes = []    
    
    for group in time_window.split(";")
      days, times = Array.new(7, false), []

      for item in group.split(" ")
        # Range of values?
        if item.include?("-")
          # Yes, Figure out if range is days or times
          range = item.split("-")
          
          if Days.include?(range[0]) 
            set_day_range(days, range[0], range[1])
          else
            times << TimeRange.new(range[0], range[1])
          end
        else
          days[Days.index(item)] = true if Days.include?(item)
        end
      end
      
      @timeframes << TimeFrame.new(days, times)
    end
  end
  
  # Set days in given range in the input array
  # Inputs: days - List of days in the time window
  #         start_day, end_day - Day range to add to the window
  def set_day_range(days, start_day, end_day)
    pos =  Days.index(start_day)
    while pos != (Days.index(end_day) + 1) % 7
      days[pos] = true
      pos = (pos + 1) % 7
    end
  end
  
  # Does the given Time match this time window?
  def include?(time)
    for time_frame in @timeframes
      return true if time_frame.include?(time)
    end

    return (@timeframes.size == 0) # Empty time string matches all times
  end
  
  private :set_day_range  
end
