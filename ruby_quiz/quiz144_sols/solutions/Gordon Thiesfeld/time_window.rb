require 'runt_ext'

module Runt

  #extends REWeek to allow for spanning across weeks
  class REWeek

    def initialize(start_day,end_day=6)
      @start_day = start_day
      @end_day = end_day
    end

    def include?(date)
      return true if  @start_day==@end_day
      if @start_day < @end_day
        @start_day<=date.wday && @end_day>=date.wday
      else
        (@start_day<=date.wday && 6 >=date.wday) || (0 <=date.wday && @end_day >=date.wday)
      end
    end

  end

  class StringParser < Runt::Intersect

    def initialize(string)
      super()
      add parsed(string)
    end

    #recursive method to parse input string
    def parse(token)
      case token
      when ""
        REWeek.new(0)
      when /^(.+);(.+)/ # split at semicolons
        parse($1) | parse($2)
      when /(\D+) (\d.+)/ # split days and times
        parse($1) & parse($2)
      when /(\D+) (\D+)/, /(\d+-\d+) (\d+-\d+)/ # split at spaces
        parse($1) | parse($2)
      when /([A-Z][a-z][a-z])-([A-Z][a-z][a-z])/ # create range of days
        REWeek.new(Runt.const_get($1), Runt.const_get($2))
      when /([A-Z][a-z][a-z])/ # create single day
        DIWeek.new(Runt.const_get($1))
      when /(\d\d)(\d\d)-(\d\d)(\d\d)/ #create time range
        start = Time.mktime(2000,1,1,$1.to_i,$2.to_i)
        # 0600-0900 should work like 0600-0859,
        stop = Time.mktime(2000,1,1,$3.to_i,$4.to_i) - 1
        REDay.new(start.hour, start.min, stop.hour, stop.min)
      end
    end
    alias :parsed :parse

  end

end

class TimeWindow < Runt::StringParser
end
