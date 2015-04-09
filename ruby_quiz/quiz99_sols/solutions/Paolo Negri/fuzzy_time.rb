#!/bin/ruby
class WanderingWalker
 SIGN = [1, -1]
 CHECK_LIMIT = %w(min max)
 DEFAULT_GENERATOR = lambda { |limit| rand(limit) * SIGN[rand(2)] }
 attr_reader :position, :limit, :target
 alias :level :position
 def initialize(limit, &block)
   @limit = limit
   @generator = block_given? ? block : DEFAULT_GENERATOR
   @position = 0
   generate_target
 end
 def walk(steps)
   generate_target while @position == @target
   new_pos = [(@position + direction*steps), @target].send  \
     CHECK_LIMIT[SIGN.index(direction)]
   @position = new_pos
 end
 def distance
   @target - @position
 end
 def direction
   if distance == 0 : 1 else distance/distance.abs end
 end
 private
 def generate_target
   @target = @generator.call limit
 end
end

class FuzzyTime
 FORMATS = %w(%H:%M %I:%M)
 attr_reader :fuzziness
 #two params, both optional time and an hash
 #time: a time object used as the starting point
 #hash params
 #:hidden_digits - hidden_digits number, from right
 #:precision - maximum distance from real time in seconds
 def initialize(time=Time.new, opts={})
   @internaltime = time
   @last_call = @printed_time  = time
   @precision = opts[:precision] || 300
   @fuzziness = WanderingWalker.new(@precision)
   @format = FORMATS[0]
   @hidden_digits = opts[:hidden_digits] || 1
   @sub_args = case @hidden_digits
     when 0 : [//, '']
     when 1 : [/\d$/, '~']
     when 2 : [/\d{2}$/, '~~']
     when 3 : [/\d:\d{2}$/, '~:~~']
     else
       raise "nothing to see!"
   end
 end
 def advance(secs)
   tic(secs)
 end
 def update
   tic Time.new - @last_call
 end
 def actual
   @internaltime
 end
 #switch 12 / 24h format
 def toggle_format
   @format = FORMATS[FORMATS.index(@format) == 0 ? 1 : 0]
 end
 def to_s
   @printed_time = [@printed_time, (@internaltime + fuzziness.level)].max
   @printed_time.strftime(@format).sub(*@sub_args)
 end
 private
 def tic(secs=1)
   @internaltime += secs
   @last_call = Time.new
   @fuzziness.walk secs
 end
end
