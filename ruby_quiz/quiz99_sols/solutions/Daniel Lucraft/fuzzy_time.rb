# handy stuff...
require '/home/dan/gems/activesupport-1.3.1/lib/active_support/core_ext/numeric'
require '/home/dan/gems/activesupport-1.3.1/lib/active_support/core_ext/time'

class FuzzyTime
  def initialize(time=Time.now)
    # we record the start time as it's used to reset the random number generator
    # every time we fuzzify a time
    @start_time = time

    time_mins = (time - time.beginning_of_day).to_i/60
    hours = time_mins/60
    mins = time_mins-(hours*60)
    tens = mins/10
    @time_of_nearest_ten_before_start = time_mins - mins + (tens*10) -5

    @internal_time = time
    @last_called = time
  end

  def actual
    @internal_time
  end

  def advance(secs)
    @internal_time += secs
    @last_called = Time.now
  end

  def rewind(secs)
    @internal_time -= secs
    check_valid
    @last_called = Time.now
  end

  def update
    @internal_time += Time.now - @last_called
    check_valid
    @last_called = Time.now
  end


  def set(time=Time.now)
    @internal_time = time
    check_valid
    @last_called = Time.now
  end

  # this fuzzifies the current internal time.
  def to_s
    # run through random numbers for the number of 10 minute blocks since the
    # start time, and keep the last one (switch_val)
    time_mins = ((@internal_time - @start_time.beginning_of_day).to_i)/60
    distance = time_mins - @time_of_nearest_ten_before_start
    Kernel.srand(@start_time.to_i)
    switch_val = nil
    ((distance/10)+1).to_i.times do
      switch_val = rand(10)
    end

    # the kept random number is where in the 10 minute interval around
    # the current time that the fuzzy time switches from low to high
    # E.g.
    # current time 9:12
    # interval around current time: [9:05, 9:15]
    # a switch_val of 3 means that we go from 9:0~ to 9:1~ at 9:08
    # NB we always get the same switch_val for this ten-minute block,
    # since we are resetting the generator and counting the correct number
    # of random numbers in. This is what allows random access.
    # marginal_mins is 7 in this case. (9:12-9:05)
    marginal_mins = distance - (10*(distance/10))
    if marginal_mins >= switch_val and marginal_mins >= 5
      near_time(@internal_time, :below)
    elsif marginal_mins >= switch_val and marginal_mins < 5
      near_time(@internal_time, :above)
    elsif marginal_mins < switch_val and marginal_mins >= 5
      near_time(@internal_time-10.minutes, :below)
    elsif marginal_mins < switch_val and marginal_mins < 5
      near_time(@internal_time, :below)
    end
  end

  def near_time(time, type)
    time = (time - time.beginning_of_day).to_i
    hour = time/3600
    fuzzy_min = ((time - (hour*3600))/60)/10
    fuzzy_min += 1 if type == :above
    (fuzzy_min = 0 and hour += 1) if fuzzy_min == 6
    hour = 0 if hour == 24
    if hour >= 10
      "#{hour}:#{fuzzy_min}~"
    else
      "0#{hour}:#{fuzzy_min}~"
    end
  end

  def check_valid
    if @internal_time < @start_time
      raise Exception, "Rewound past start of FuzzyTime."
    end
  end
end

if __FILE__ == $0
  ft = FuzzyTime.new
  puts ft
  step = ARGV[0].to_i || 60
  while(true)
    sleep step
    ft.advance 60
    puts ft
  end
end
