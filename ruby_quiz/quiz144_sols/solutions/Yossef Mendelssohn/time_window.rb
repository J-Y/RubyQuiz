require 'date'

class TimeWindow
  attr_reader :intervals

  def initialize(string)
    @intervals = []

    parse(string)
  end

  def include?(time)
    intervals.any? { |int|  int.include?(time) }
  end

  private

  attr_writer :intervals

  def parse(string)
    parts = string.split(';')
    parts = [''] if parts.empty?
    @intervals = parts.collect { |str|  TimeInterval.new(str) }
  end

end

class TimeInterval
  DAYS = %w(Sun Mon Tue Wed Thu Fri Sat)

  UnboundTime = Struct.new(:hour, :minute) do
    include Comparable

    def <=>(time)
      raise TypeError, "I need a real Time object for comparison" unless time.is_a?(Time)

      comp_date  = Date.new(time.year, time.month, time.mday)
      comp_date += 1 if hour == 24

      Time.mktime(comp_date.year, comp_date.month, comp_date.day, hour % 24, minute, 0) <=> time
    end
  end

  UnboundTimeRange = Struct.new(:start, :end)

  attr_reader :days, :times

  def initialize(string)
    @days  = []
    @times = []

    parse(string)
  end

  def include?(time)
    day_ok?(time) and time_ok?(time)
  end

  private

  attr_writer :days, :times

  def parse(string)
    unless string.empty?
      string.strip.split(' ').each do |segment|
        if    md = segment.match(/^(\d{4})-(\d{4})$/)
          self.times += [ UnboundTimeRange.new(UnboundTime.new(*md[1].unpack('A2A2').collect { |elem|  elem.to_i }), UnboundTime.new(*md[2].unpack('A2A2').collect { |elem|  elem.to_i })) ]
        elsif md = segment.match(/^(\w+)(-(\w+))?$/)
          if md[2]
            start_day = DAYS.index(md[1])
            end_day   = DAYS.index(md[3])

            if start_day <= end_day
              self.days += (start_day .. end_day).to_a
            else
              self.days += (start_day .. DAYS.length).to_a + (0 .. end_day).to_a
            end
          else
            self.days += [DAYS.index(md[1])]
          end
        else
          raise ArgumentError, "Segment #{segment} of time window incomprehensible"
        end
      end
    end

    self.days  = 0..DAYS.length if days.empty?
    self.times = [ UnboundTimeRange.new(UnboundTime.new(0, 0), UnboundTime.new(24, 0)) ] if times.empty?
  end

  def day_ok?(time)
    days.any? { |d|  d == time.wday }
  end

  def time_ok?(time)
    times.any? { |t|  t.start <= time and t.end > time }
  end
end
