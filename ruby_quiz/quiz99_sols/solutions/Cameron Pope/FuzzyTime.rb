# Fuzzy Time class that reports a time that is always within a given
# slop factor to the real time. The user specifies the amount of
# fuzzyiness to the time and the display obscures the minutes field.
#
# This class works by maintaining the actual time it represents, and
# calculating a new fuzzy time whenever it is asked to display the
# fuzzy time. It keeps a low water mark so an earlier time is never
# displayed.
#
class FuzzyTime
  # Initialize this object with a known time and a number of minutes
  # to randomly vary
  #
  # time          -> initial time
  # fuzzy_minutes -> number of minutes to randomly vary time
  def initialize(time=Time.now, fuzzy_minutes=5)
    @fuzzy_factor = fuzzy_minutes
    @current_time = time
    set_low_water_mark
    set_updated
  end

  # Print the fuzzy time in a format obscuring the last number of the
  # time.
  def to_s
    ft = fuzzy_time
    s = ft.strftime("%H:%M")
    s[4] = '~'
    s
  end

  # Manually advance time by a certain number of seconds. Seconds
  # cannot be negative
  #
  # seconds -> number of seconds to advance. Will throw exception
  #   if negative
  def advance(seconds)
    raise "advance: seconds cannot be negative" if seconds < 0
    @current_time = @current_time + seconds
    set_updated
  end

  # Update the current time with the number of seconds that has
  # elapsed since the last time this method was called
  def update
    @current_time = @current_time + update_interval
    set_updated
  end

  # Reports real time as Time
  def actual
    @current_time
  end

private
  # sets the current low water mark. This is so the fuzzy time never
  # goes backwards
  def set_low_water_mark
    @low_water_mark = @current_time - (@fuzzy_factor*60)
  end

  # Updates the last time initialize, advance or update was called
  def set_updated
    @last_updated = Time.now
  end

  # Gets the number of seconds since the last update
  def update_interval
    Time.now - @last_updated
  end

  # Sets fuzzy time to be +/- the fuzzy factor from the current time,
  # while ensuring that we never return an earlier time than the one
  # returned last time we were called.
  def fuzzy_time
    fuzzy_seconds = @fuzzy_factor * 60

    # Raise the low watermark if it is lower than allowed, if we
    # advanced by a huge degree, etc.
    @low_water_mark =
      [@low_water_mark, @current_time - fuzzy_seconds].max

    # Compute a new random time, and set it to be the fuzzy time if
    # it is higher than the low water mark. The algorithm is biased
    # to return a negative time. This is to compensate for the low
    # water mark. We want the time to be behind as much as it is
    # ahead. At least 60 percent of the time the time will not
    # advance here.
    random_time = @current_time +
      (rand(fuzzy_seconds*5) - fuzzy_seconds*4)
    fuzzy_time = [@low_water_mark, random_time].max

    # Update the low water mark if necessary
    @low_water_mark = [@low_water_mark, fuzzy_time].max

    fuzzy_time
  end
end
