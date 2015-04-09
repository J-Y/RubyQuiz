#!/usr/bin/env ruby
#
# Marcel Ward   <wardies ^a-t^ gmaildotcom>
# Sunday, 29 October 2006
# Solution for Ruby Quiz number 99
#
################################################
# fuzzy_time.rb

class FuzzyTime
 attr_reader :actual, :timed_observation_period

 # If the time passed is nil, then keep track of the time now.
 def initialize(tm=nil, range_secs=600, disp_accuracy_secs=range_secs,
                 fmt="%H:%M", obs_period=nil)
   @actual = @last_update = @next_diff = tm || Time.now
   @realtime = tm.nil?
   @maxrange = range_secs
   @display_accuracy = @best_accuracy = disp_accuracy_secs
   @tformat = fmt
   @last_observed = @max_disptime = Time.at(0)
   @timed_observation_period = obs_period
 end

 def to_s
   @last_update = Time.now
   @actual = @last_update if @realtime

   check_observation_period unless @timed_observation_period.nil?

	# We only calculate a new offset each time the last offset times out.
   if @next_diff <= @actual
     # Calculate a new time offset
     @diff = rand(@maxrange) - @maxrange/2
     # Decide when to calculate the next time offset
     @next_diff = @actual + rand(@maxrange)
   end
   @last_observed = @actual

   # Don't display a time less than the time already displayed
   @max_disptime = [@max_disptime, @actual + @diff].max

   # Take care to preserve any specific locale (time zone / dst) information
   # stored in @actual - for example, we cannot use Time::at(Time::to_i).
   disptime = @max_disptime.strftime(@tformat)

   # Lop off characters from the right of the display string until the
   # remaining string matches one of the extreme values; then fuzz out the
   # rightmost digits
   (0..disptime.size).to_a.reverse.each do
     |w|
     [@display_accuracy.div(2), - @display_accuracy.div(2)].map{
       |offs|
       (@max_disptime + offs).strftime(@tformat)
     }.each do
       |testtime|
       return disptime[0,w] + disptime[w..-1].tr("0123456789", "~") if \
         disptime[0,w] == testtime[0,w]
     end
   end
 end

 def advance(secs)
   if @realtime
     @actual = Time.now + secs
     # Once a real-time FuzzyTime is advanced, it can never again be
     # real-time.
     @realtime = false
   else
     @actual += secs
   end
   @last_update = Time.now
 end

 def update
   diff = Time.now - @last_update
   @actual += diff
   @last_update += diff
   # By calling update, you are effectively saying "set a fixed time"
   # so we must disable the real-time flag.
   @realtime = false
 end

 def accuracy
   "+/- #{@maxrange/2}s"
 end

 def dump
   "actual: #{@actual.strftime("%Y-%m-%d %H:%M:%S")}, " \
		"diff: #{@diff}, " \
		"next_diff: #{@next_diff.strftime("%Y-%m-%d %H:%M:%S")}, " \
		"accuracy: #{@display_accuracy}"
 end

private
 def check_observation_period
   # Is the clock being displayed too often?

   # Although this method seems to work, it may be a bit simplistic.
   # Proper statistical / mathematical analysis and a proper understanding
   # of the human ability to count seconds may be necessary to determine
   # whether this still gives away too much info for the average observer.

   patience = @actual - @last_observed

   if patience < @timed_observation_period / 2
     # Worsen display accuracy according to how impatient the observer is.
     @display_accuracy += (2 * @best_accuracy *
                           (@timed_observation_period - patience)) /
                           @timed_observation_period
   elsif patience < @timed_observation_period
     # Immediately punish impatience by enforcing a minumum accuracy
     # twice as bad as the best possible.
     # Don't give too much away but allow the accuracy to get slowly better
     # if the observer is a bit more patient and waits over half the
     # observation period
     @display_accuracy = [
         2 * @best_accuracy,
         @display_accuracy - ((@best_accuracy * patience) /
                               @timed_observation_period)
       ].max
   else
     # The observer has waited long enough.
     # Reset to the best possible accuracy.
     @display_accuracy = @best_accuracy
   end
 end
end

def wardies_clock
 # Get us a real-time clock by initializing Time with first parameter==nil
 # Make the seconds harder to guess by expanding the range to +/- 15s whilst
 # keeping the default display accuracy to +/- 5 secs.  The user will have
 # to wait 30s between observations to see the clock with best accuracy.
 ft = FuzzyTime.new(nil, 30, 10, "%H:%M:%S", 30)

 # This simpler instantiation does not check the observation period and
 # shows "HH:M~". (This is the default when no parameters are provided)
 #ft = FuzzyTime.new(nil, 600, 600, "%H:%M")

 puts "** Wardies Clock\n"
 puts "**\n** Observing more often than every " \
   "#{ft.timed_observation_period} seconds reduces accuracy" \
   unless ft.timed_observation_period.nil?
 puts "**\n\n"

 loop do
   puts "\n\nTime Now: #{ft.to_s}  (#{ft.accuracy})\n\n" \
     "-- Press Enter to observe the clock again or " \
     "q then Enter to quit --\n\n"

   # Flush the output text so that we can scan for character input.
   STDOUT.flush

   break if STDIN.getc == ?q
 end
end


def clocks_go_back_in_uk
 # Clocks go back in the UK on Sun Oct 29. (+0100 => +0000)
 # Start at Sun Oct 29 01:58:38 +0100 2006
 ft = FuzzyTime.new(Time.at(Time.at(1162083518)))

 # In the UK locale, we see time advancing as follows:
 # 01:5~
 # 01:5~
 # 01:0~  (clocks gone back one hour)
 # 01:0~
 # ...
 # 01:0~
 # 01:1~

 60.times do
   puts ft.to_s
   ft.advance(rand(30))
 end
end

def full_date_example
 # Accuracy can be set very high to fuzz out hours, days, etc.
 # E.g. accuracy of 2419200 (28 days) fuzzes out the day of the month
 # Note the fuzz factoring does not work so well with hours and
 # non-30-day months because these are not divisble exactly by 10.

 tm = FuzzyTime.new(nil, 2419200, 2419200, "%Y-%m-%d %H:%M:%S")
 300.times do
   puts "#{tm.to_s} (#{tm.dump})"
   # advance by about 23 days
   tm.advance(rand(2000000))
   #sleep 0.2
 end
end

# Note, all the examples given in the quiz are for time zone -0600.
# If you are in a different timezone, you should see other values.
def quiz_example
 ft = FuzzyTime.new                      # Start at the current time
 ft = FuzzyTime.new(Time.at(1161104503)) # Start at a specific time

 p ft.to_s                               # to_s format

 p ft.actual, ft.actual.class            # Reports real time as Time
 #=> Tue Oct 17 11:01:36 -0600 2006
 #=> Time

 ft.advance( 60 * 10 )                   # Manually advance time
 puts ft                                 # by a specified number of
 #=> 11:0~                               # seconds.

 sleep( 60 * 10 )

 ft.update              # Automatically update the time based on the
 puts ft                # time that has passed since the last call
 #=> 11:1~              # to #initialize, #advance or #update
end

if __FILE__ == $0
 wardies_clock
 #clocks_go_back_in_uk
 #full_date_example
 #quiz_example
end
