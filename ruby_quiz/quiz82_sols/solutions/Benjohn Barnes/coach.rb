def count_down(s, activity)
  # Encouragement for the last few seconds (which could get annoying on longer runs?).
  counts =  { 10 =>  "10 more seconds.",
              20 =>  "20 seconds to go.",
              30 =>  "Half a minute to go.",
              60 =>  "You have 1 more minute of #{activity} left.",
              90 =>  "You have 1 and a half minutes of #{activity} to go."}

  # Add in encouragement / prompts for minutes.
  [2, 3, 4, 6, 8, 10, 12, 15, 20, 25, 30].each {|m| counts[m*60] = "You have #{m} minutes of #{activity} to go."}

  # Build an ordered array of the possible lengths of time, and find the index of this
  # activity's length.
  times = counts.keys.sort
  start_index = times.index(s); raise "#{s} is not a known time." unless start_index

  # Count down through the time prompts. I bet inject could do this too :)
  start_index.downto(0) do |i|
    this_time = times[i]
    next_time = i>0 ? times[i-1] : 0
    delay_to_next = this_time - next_time
    message = counts[this_time]
    say message
    wait delay_to_next
  end
end

def say(to_say)
  system("say \"#{to_say}\"")
end

def wait(s)
  @wait_until ||= Time.now
  @wait_until += s
  while((w = @wait_until - Time.new) > 0)
    sleep w
  end
end

# For testing it's really helpful to redefine the above to...
def say(m); puts m; end
def wait(s); puts "Waiting for #{s} seconds."; end

# Code to deal with just week 3!
def week_3
  wait(0)
  say "Start your first short run."
  count_down(90, 'running')
  say "Stop running now. You have 1 long run and two short ones left."
  count_down(90, 'walking')

  say "Start the first long run now."
  count_down(3*60, 'running')
  say "Stop running now. You have a short run and a long run left."
  count_down(3*60, 'walking')

  say "Start your second short run."
  count_down(90, 'running')
  say "Stop running. You have 1 more long run left."
  count_down(90, 'walking')

  say "Start your last run now."
  count_down(3*60, 'running')
  say "Stop running. After this walk, you will have finished."
  count_down(3*60, 'walking')

  say "Great! You've finished for today."
end

# Call week 3's code.
week_3
