require 'core_ext'

class Program

  WEEKDAYS = { 'sun' => 0, 'mon' => 1, 'tue' => 2, 'wed' => 3,
               'thu' => 4, 'fri' => 5, 'sat' => 6 }

  attr_reader :start, :end, :channel, :days

  def initialize(program)
    @start = program[:start]
    @end = program[:end]
    @channel = program[:channel]
    @days = program[:days]

    raise "Missing start or end" if @start.nil? || @end.nil?
    raise "Wrong start or end types" unless (@start.is_a?(Time) && @end.is_a?(Time)) ||
                                            (@start.is_a?(Integer) && @end.is_a?(Integer))
    raise "Invalid program" if weekly? && (@start.is_a?(Time) || @end.is_a?(Time))
    raise "End must come after Start" if !weekly? && @start > @end
    raise "Missing channel" if !@channel.is_a?(Integer)
    raise "Invalid weekday" if @days.is_a?(Array) && @days.any? { |day| WEEKDAYS[day] == nil }
  end

  def weekly?
    !@days.nil?
  end

  def on?(time)
    if weekly? #weekly program
      for day in @days
        if WEEKDAYS[day] == time.wday
          return @channel if time.secs >= @start && time.secs <= @end
        end
      end
    else #specific time
      return @channel if time >= @start && time <= @end
    end
    nil
  end

end
