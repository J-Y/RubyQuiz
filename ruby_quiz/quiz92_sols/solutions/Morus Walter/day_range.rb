#! /usr/bin/ruby

class Array
  # split array into array of contiguous slices
  # a slice is contiguous if each item value is the successor of the
  # value of the previous item
  def split_contiguous()
    self.inject( [ [] ] ) do | list, item |
      list[-1].empty? || list[-1][-1].succ == item ? 
	      list[-1] << item : list << [ item ]
      list
    end
  end
end

class DayRange
  # define weekday names as constants
  @@WEEKDAY = [ nil, 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun' ]
  @@FULLWEEKDAY = [ nil, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' ]

  # prepare for fast weekday to day of week resolution
  @@DAYOFWEEK = {}
  @@WEEKDAY[1,7].each_with_index { | day,idx | @@DAYOFWEEK[day] = idx + 1 }
  @@FULLWEEKDAY[1,7].each_with_index { | day,idx | @@DAYOFWEEK[day] = idx + 1 }

  # take a list of objects or arrays of objects and convert them to an
  # unique sorted array of day of week numbers
  def initialize( *days )
    @days = days.flatten.collect do | day0 |
      day = @@DAYOFWEEK[day0] || day0.to_i # allow for non integer input
      raise ArgumentError.new(day0.inspect) if day < 1 or day > 7 # check input
      day
    end.sort.uniq
  end

  # provide a list of weekdays or weekday ranges
  def day_range( full = false )
    weekday = full ? @@FULLWEEKDAY : @@WEEKDAY
    @days.split_contiguous.inject( [] ) do | list, range |
      list << ( range.size <= 2 ? weekday[range[0]] : 
		 weekday[range[0]] + '-' + weekday[range[-1]] )
      list << weekday[range[1]] if range.size == 2
      list
    end
  end

  def to_s( full = false )
    day_range(full).join(', ')
  end
end

puts DayRange.new( 1,'Tue',3,4,5,6,7 ).to_s(true)
puts DayRange.new(1,2,3,4,5,6,7)
puts DayRange.new(1,2,3,6,7)
puts DayRange.new(1,3,4,5,6)
puts DayRange.new(2,3,4,6,7)
puts DayRange.new(1,3,4,6,7)
puts DayRange.new(7)
puts DayRange.new(1,7)
puts DayRange.new(1,8)
