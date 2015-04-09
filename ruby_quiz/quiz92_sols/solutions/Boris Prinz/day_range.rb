require 'date'

# A day of the week. In calculations and comparisons a WeekDay behaves
# like an integer with 1=Monday, ..., 7=Sunday.
class WeekDay
  # A WeekDay can be constructed from a number between 1 and 7 or a
  # string like 'mon' or 'monday'.
  def initialize(arg)
    case arg
    when Fixnum
      if arg < 1 or arg > 7
        raise ArgumentError.new("day number must be between 1 and 7")
      end
      @daynum = arg
    when WeekDay
      @daynum = arg.to_i
    else
      s = arg.to_s.downcase
      if Date::ABBR_DAYS.has_key?(s)
        @daynum = Date::ABBR_DAYS[s]
      elsif Date::DAYS.has_key?(s)
        @daynum = Date::DAYS[s]
      else
        raise ArgumentError.new("#{s} is not a day")
      end
      @daynum = 7 if @daynum == 0
    end
  end

  # Returns the abbreviated name of the day (e.g. 'Mon')
  def to_s
    Date::ABBR_DAYNAMES[@daynum % 7]
  end

  # Returns the number of the day (1=Monday, ..., 7=Sunday)
  def to_i
    @daynum
  end

  %w{== <=> + - >}.each do |meth|
    define_method meth do |other|
      self.to_i.send(meth, other.to_i)
    end
  end
end

# A Range of days between two days of the week.
class DayRange < Range
  # The first and last day of the range can be given as instances of
  # class WeekDay, numbers or strings.
  def initialize(from, to, exclusive=false)
    from_day = WeekDay.new(from)
    to_day   = WeekDay.new(to)
    super(from_day, to_day, exclusive)
  end

  # Returns a string representation of the range. Two consecutive days
  # are returned as a list, e.g. 'Mon, Tue'.
  def to_s
    from = self.begin.to_s
    to   = self.end.to_s

    case self.end - self.begin
    when 0 then return from
    when 1 then return from + ', ' + to
    else        return from + '-'  + to
    end
  end
end

# An array containing several DayRange instances.
class DayRangeArray < Array
  private
  def normalize_days days
    days.collect{|d| WeekDay.new(d)}.sort.uniq
  end

  # Given a list of days (as numbers or strings), an array of
  # DayRanges is created.
  def initialize(*days)
    return if days.size == 0

    a = normalize_days(days)
    first = a.first

    1.upto(a.size - 1) do |i|
      if a[i] > a[i-1] + 1
        self << DayRange.new(first, a[i-1])
        first = a[i]
      end
    end
    self << DayRange.new(first, a.last)
  end

  public
  # The DayRanges are separated by comma. For example:
  #   DayRangeArray.new(1, 2, 3, 5).to_s    # => "Mon-Wed, Fri"
  def to_s
    self.join(', ')
  end
end
