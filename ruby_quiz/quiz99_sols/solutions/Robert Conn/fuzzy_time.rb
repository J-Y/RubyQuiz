class FuzzyTime

  attr_reader :actual, :display

  def initialize(*start_time)
    @current_systime = Time.new
    @actual = start_time[0] || Time.new
    @last_displayed = @actual
  end

  def to_s
    # Decide whether to go forward or back 5 mins
    if rand(2) == 1
      @display = @actual + (5 * 60)
    else
      @display = @actual - (5 * 60)
    end

    # If the time we are going to display is before what was last displayed, don't do it
    if @display < @last_displayed
      @display = @last_displayed
    end

    @last_displayed = @display

    "#{"%02d" % @display.hour}:#{("%02d" % @display.min.to_s)[0..0]}~"
  end

  # Advance the actual time by a number of seconds, reset the system time record so that
  # update will work
  def advance(secs)
    @actual += secs
    @current_systime = Time.new
  end

  # Work out the relative time difference since the last initialize, advance or update
  # and apply this to the actual time
  def update
    diff = Time.new - @current_systime
    @actual += diff.to_i
    @current_systime = Time.new
  end

end
