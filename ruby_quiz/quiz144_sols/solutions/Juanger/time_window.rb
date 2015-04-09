class TimeWindow

  Days = { "Mon" => 0, "Tue" => 1, "Wed" => 2, "Thu" => 3, "Fri" => 4, "Sat" => 5, "Sun" => 6}

  def initialize (window)
    @window = window
    @ranges = []
    parse_window
  end

  def include? (time)
    hour = time.strftime("%H%M").to_i
    day = time.strftime("%w").to_i
    req = (day-1)*10000+hour
    puts "#{req}"
    result = false
    @ranges.each{ |range|
      if range[0] <= req && req < range[1]
        result = true
      end
    }
    result
  end

  private

  #Parse the input
  def parse_window
    regex = /((?:Mon[ -]?|Tue[ -]?|Wed[ -]?|Thu[ -]?|Fri[ -]?|Sat[ -]?|Sun[ -]?)+)?((?:[012]\d[0-6]\d-[012]\d[0-6]\d[ ]?)+)?/
    @window.split(";").each { |window|
      window.strip!
      match = regex.match(window)

      # it has days
      if match[1]
        days = parse_days match[1]
      else
        days = [[0,6]]       # everyday
      end

      # it has hours
      if match[2]
        time = parse_time match[2]
      else
        time = [[0,2400]]   # all day
      end

      days.each {|dr|
        time.each {|tr|
          @ranges << [dr[0]*10000+tr[0], dr[1]*10000+tr[1]]
        }
      }
    }
  end

  def parse_days (days)
    result = []
    days.scan(/(?:(Mon|Tue|Wed|Thu|Fri|Sat|Sun)-(Mon|Tue|Wed|Thu|Fri|Sat|Sun)|(Mon|Tue|Wed|Thu|Fri|Sat|Sun))/) {
      if $3                # it's just one day
        result << [Days[$3],Days[$3]]
      else                # it's a range
        result << [Days[$1],Days[$2]]
      end
    }
    result
  end

  def parse_time (time)
    result = []
    time.scan(/([012]\d[0-6]\d)-([012]\d[0-6]\d)/) {
      result << [$1.to_i, $2.to_i]
    }
    result
  end
end
