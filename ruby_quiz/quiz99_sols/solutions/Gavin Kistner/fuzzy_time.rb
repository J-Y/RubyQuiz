class Time
  def round_to( seconds )
    seconds = seconds.round
    Time.at( self.to_i / seconds * seconds )
  end
end

class FuzzyTime
  FIVE_MINS = 5 * 60
  TEN_MINS = 10 * 60
  attr_reader :actual
  def initialize( start_time=Time.new )
    @last_fuzzy = @actual = @fuzzy = start_time
  end

  def update
    now = Time.new
    elapsed = now - ( @last_update || now )
    advance( elapsed )
    @last_update = now
  end

  def advance( seconds_forward )
    @actual += seconds_forward    

    # Randomly move forward, centered around the desired seconds
    @fuzzy += seconds_forward * 2 if rand < 0.5

    # Ensure the fuzzy time is within legal bounds
    overshoot = @fuzzy - @actual
    if overshoot > FIVE_MINS
      @fuzzy = @actual + FIVE_MINS
    elsif overshoot < -FIVE_MINS
      @fuzzy = @actual - FIVE_MINS
    end

    # Ensure that the fuzzy time is not less than the last *displayed*
    if @fuzzy.round_to( TEN_MINS ) < @last_fuzzy.round_to( TEN_MINS )
      if $DEBUG
        puts "It is #{@actual.short}; " +
           "I wanted to show #{@fuzzy.short} (#{@fuzzy.to_fuzzy})," +
           " but I last showed " +
           "#{@last_fuzzy.short} (#{@last_fuzzy.to_fuzzy})"
      end
      @fuzzy = @last_fuzzy
    end
  end

  def to_s
    # only record the last *displayed* time, to allow backtracking
    # as often as possible
    @last_fuzzy = @fuzzy
    s = @fuzzy.strftime("%H:%M")
    s[4] = "~"
    s
  end

end
