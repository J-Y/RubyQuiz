class TimeWindow
  DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
  
  def initialize(time_window)
    @intervals_in_days = []
    time_window.split(";").each do |interval|
      @intervals_in_days += TimeWindow.parse_interval(interval)
    end
  end
  
  def include?(time)
    @intervals_in_days.empty? or @intervals_in_days.any? { |i| i.include?(time)}
  end
  
  private
  
  def TimeWindow.parse_interval(interval)
    alldays = []
    alltimeintervals = []
    
    interval.split(" ").each do |token|
      case token
      when /^\D{3}$/
        alldays += [DAYNAMES.index(token)]
      when /^\D{3}-\D{3}$/
        days = token.split("-")
        alldays += TimeWindow.days_in_interval(days[0], days[1])
      when /^\d{4}-\d{4}$/
        timeintervals = token.split("-")
        alltimeintervals += [[timeintervals[0], timeintervals[1]]]
      end
    end
    
    alldays = (0..6).to_a if alldays.empty?
    alltimeintervals = [["0000", "2400"]] if alltimeintervals.empty?
    
    interval_in_days = []
    alldays.each do |day|
      alltimeintervals.each do |timeinterval|
        interval_in_days << IntervalInDay.new(day, timeinterval[0], timeinterval[1])
      end
    end
    
    return interval_in_days
  end
  
  def TimeWindow.days_in_interval(beginday, endday)
    index_begin = DAYNAMES.index(beginday)
    index_end = DAYNAMES.index(endday)
    if index_begin <= index_end
      return (index_begin..index_end).to_a
    else
      return (index_begin..6).to_a + (0..index_end).to_a
    end
  end
end

class IntervalInDay
  def initialize(weekday, starttime, endtime)
    @weekday, @starttime, @endtime = weekday, starttime.to_i, (endtime.to_i - 1)
  end
  
  def include?(time)  
     time.wday == @weekday &&
     time.strftime("%H%M").to_i.between?(@starttime, @endtime)
  end
end
