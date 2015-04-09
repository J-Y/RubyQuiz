#!/usr/bin/env ruby
# Author: Kamal Fariz

class DayRange
  FULLDAY = %w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday }
  SHORTDAY = FULLDAY.map { |d| d[0, 3] }
  
  def initialize(*input)
    @days = []
    input.each { |day| 
      case day.to_s.size
      when 1
        raise ArgumentError unless (1..7).include?(day)
        @days << day - 1 # normalize to 0-based index
      when 3
        raise ArgumentError unless SHORTDAY.include?(day)
        @days << SHORTDAY.index(day)
      else
        raise ArgumentError unless FULLDAY.include?(day)
        @days << FULLDAY.index(day)
      end
      @days.uniq!
      @days.sort!
    }
  end
  
  def to_s
    # partition the array into groups of consecutive numbers
    partitions = @days.inject([[]]) { |partition, day|
      if partition.last.empty? || (day - partition.last.last == 1)
        partition.last << day
      else
        partition << [day]
      end
      partition
    }

    # transform the partition into array of day name strings
    partitions.inject([]) { |days, partition|
      if partition.size > 2
        days << "#{SHORTDAY[partition.first]}-#{SHORTDAY[partition.last]}"
      else
        partition.each { |day| days << SHORTDAY[day] }
      end
      days
    }.join(", ")
  end
end
