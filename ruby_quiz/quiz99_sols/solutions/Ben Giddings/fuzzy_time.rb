class FuzzyTime
  MAX_OFFSET = 5*60

  def initialize(*args)
    now = Time.new
    @internal_time = args[0] || now
    @time_offset = now - @internal_time
    @fuzzy_secs = 0
    @last_calc = Time.new
  end

  def actual
    @internal_time
  end

  def update
    @internal_time = Time.new + @time_offset
  end

  def advance(amount)
    @time_offset += amount.to_i
  end

  def calc_offset
    # Choose a new  offset that's between +/- 5 mins.   If it has been
    # less than 5 mins since the last offset calc, choose that time as
    # a max delta (this makes sure time is always going forward)

    time_from_last_calc = (Time.new - @last_calc).to_i

    if time_from_last_calc > 0
      begin
        max_delta = [MAX_OFFSET, time_from_last_calc].min

        delta = rand((2*max_delta) + 1) - max_delta
      end until (delta + @fuzzy_secs).abs < MAX_OFFSET
      @fuzzy_secs += delta

      puts "Fuzzy secs now: #{@fuzzy_secs}"

      @last_calc = Time.new
    end
    @fuzzy_secs
  end

  def get_time
    fuzzy_hour = @internal_time.hour
    fuzzy_min = @internal_time.min
    fuzzy_sec = @internal_time.sec + calc_offset

    if fuzzy_sec > 60
      fuzzy_sec -= 60
      fuzzy_min += 1
    end

    if fuzzy_sec < 0
      fuzzy_sec += 60
      fuzzy_min -= 1
    end


    if fuzzy_min > 60
      fuzzy_min -= 60
      fuzzy_hour = (fuzzy_hour + 1) % 24
    end

    if fuzzy_min < 0
      fuzzy_min += 60
      fuzzy_hour = (fuzzy_hour + 23) % 24
    end

    [fuzzy_hour, fuzzy_min, fuzzy_sec]
  end

  def to_s
    fuzzy_hour, fuzzy_min, fuzzy_sec = get_time
    "#{fuzzy_hour}:#{fuzzy_min / 10}~"
    # "#{fuzzy_hour}:#{fuzzy_min / 10}~ (#{fuzzy_hour}:#{"%02d" % fuzzy_min}:#{"%02d" % fuzzy_sec})"
  end

end

if $0 == __FILE__
  t = FuzzyTime.new
  10.times do
    puts t, Time.new
    sleep 10
    t.update
  end
end
