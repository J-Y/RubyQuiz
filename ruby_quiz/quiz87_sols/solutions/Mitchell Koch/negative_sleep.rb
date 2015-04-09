#! /usr/bin/env ruby
#
# Negative sleep via time machine
# Author: Mitchell Koch
#
# Definition of negative sleep: the statement after the sleep call is
# run that many seconds before the statement before the call, meaning
# that is equivalent to the order of the two statements as well as the
# sign of the number of seconds to sleep both being inverted.
#
# If there are three or more statements with negative sleeps between
# them, they should be inverted two at a time from top to bottom.
#
# Using negative sleep before or after everything else is called is
# undefined and raises errors here.

class TimeMachine
  def initialize
    @statements = []
    yield self
  end

  # Give the machine something to do
  def do(&proc)
    @statements << proc
    if @swapidx
      if @swapidx < 0
        # calling at beginning error
        raise "Cannot warp time before anything else is called"
      end
      # swap the last statement and the one before the sleep call
      @statements[-1], @statements[@swapidx] = 
        @statements[@swapidx], @statements[-1]
      @swapidx = false
    end
  end

  # Define the time between two events
  def sleep(n)
    @swapidx = @statements.size-1 if n < 0
    @statements << Proc.new { Kernel.sleep n.abs }
  end

  # Activate the machine
  def run
    if @swapidx
      # calling at end error
      raise "Cannot warp time after everything else is called"
    end
    @statements.each { |s| s.call }
  end
end

# For minus one seconds,
# wuh?
# sleep...
TimeMachine.new do |t|
  t.do { puts "sleep..." }
  t.sleep -1
  t.do { puts "For minus one seconds, " }
  t.sleep -1
  t.do { puts "wuh?" }
end.run

