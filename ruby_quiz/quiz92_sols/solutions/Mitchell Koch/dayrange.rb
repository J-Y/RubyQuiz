#!/usr/bin/env ruby

class DayRange

  WEEKDAYS = %w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday }
  WDA = WEEKDAYS.map { |d| d[0..2] } # 3-letter abbrevs
  
  def initialize(*args)
    @days = args.map do |arg|
      daynum = nil
      case arg
      when Integer
        if 0 < arg && arg <= WEEKDAYS.size
          daynum = arg
        end
      when String
        days_arr = (arg.size == 3 ? WDA : WEEKDAYS)
        if idx = days_arr.index(arg)
          daynum = idx + 1
        end
      end
      daynum or raise ArgumentError
    end.uniq.sort
    raise ArgumentError if @days.empty?
  end
  
  def to_s
    adj = [[]]
    @days.each do |day|
      if adj.last.empty? or adj.last.last == day-1
        adj.last << day
      else
        adj << [day]
      end
    end

    adj.map do |r|
      r.map!{|n| WDA[n-1]}
      if r.size > 1 
        sep = r.size == 2 ? ", " : "-"
        r.first.to_s + sep + r.last.to_s 
      else
        r.first
      end
    end.join(", ")
  end
end
