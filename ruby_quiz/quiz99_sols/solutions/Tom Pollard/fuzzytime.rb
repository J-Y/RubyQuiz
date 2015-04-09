#!/usr/bin/env ruby
#  Fuzzy time module
#  Author: Tom Pollard <pollard@earthlink.net>
#
class FuzzyTime
  attr_reader :actual, :current, :updated, :update_count
  attr_accessor :am_pm, :fuzz, :wobble, :method

  # Return a new FuzzyTime clock, intialized to the given time.
  # If no intial time is specified, the current time is used.
  # The default fuzz is 1 digit; the default wobble is 5 minutes;
  # times are represented in 12-hour style by default.
  # 
  def initialize ( actual=nil )
    @actual = actual || Time.new()   # the actual time (Time)
    @current = nil                   # the time that we report (Time)
    @updated = Time.new              # when @current was last updated (Time)
    @wobble = 5                      # the maximum error in @current (minutes)
    @fuzz = 1                        # the number of digits to fuzz out (int)
    @method = 3                      # the update algorithm to use (int)
    @am_pm = false                    # report 12-hour time? (boolean)
    @current_offset = @wobble - rand(2*@wobble+1)
    @current = @actual + offset
    @current_offset = @current.to_i/60 - @actual.to_i/60
    @update_count = 1                # number of times time was updated (int)
  end

  # Advance the actual time by the given number of seconds
  # (The reported time may or may not change.)
  def advance ( delta=0 ) 
    @actual += delta
    @current = @actual + offset
    @current_offset = @current.to_i/60 - @actual.to_i/60
    @updated = Time.new
    @update_count += 1
    self
  end

  # Advance the actual time to account for the time since it was last changed.
  # (The reported time may or may not change.)
  def update
    advance( (Time.new - @updated).to_i )
  end

  # Calculate a new offset (in minutes) between the actual and reported times.
  # (This is called whenever the actual time changes.)
  def offset
    max_range = 2*@wobble + 1
    min_offset = @current.to_i/60 - @actual.to_i/60
    if @current.nil?  || min_offset < -@wobble
      range = max_range
    else
      range = @wobble - min_offset + 1
    end
    range = max_range if range > max_range

    if range == 0
      new_offset = 0
    else
      if @method == 1
        # pick a new offset within the legal range of offsets.
        new_offset = @wobble - rand(range)
      elsif @method == 2
        # pick a new offset within the range of allowable errors.
        # if it would require the time to regress, don't change the reported time.
        new_offset = @wobble - rand(max_range)
        new_offset = min_offset if new_offset < min_offset
      else
        new_offset = @current_offset + 1 - rand(3)
        new_offset = @wobble if new_offset > @wobble
        new_offset = -@wobble if new_offset < -@wobble
        new_offset = min_offset if new_offset < min_offset
      end
    end
    return 60 * new_offset
  end

  # Report the difference (in minutes) between the reported and actual times.
  def error
    @current_offset
  end

  # Return a string representation of the fuzzy time.
  # The number of digits obscured by tildes is controlled by the 'fuzz' attribute.
  # Whether the time is in 12- or 24-hour style is controlled by 'am_pm'.
  def to_s
    if @am_pm
      display = @current.strftime("%I:%M")
    else
      display = @current.strftime("%H:%M")
    end
    @fuzz.times { display.sub!(/\d(\D*)$/, '~\1') } if @fuzz > 0
    display
  end
end
