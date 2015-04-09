class FuzzyTime
 # if 24 then show in 24 hour format, else 12 hour format
 attr_accessor :mode

 def initialize(startAt = Time.now, variance = 5*60)
   @time = Time.at(startAt)
   @offset = Time.now - @time
   @variance = variance
   @mintime = Time.at(@time.to_i - @variance).to_i
   @mode = 24
 end

 def to_s
   t = @time.to_i - @variance + rand(@variance * 2)
   @mintime = @mintime > t ? @mintime : t
   now = Time.at(@mintime)
   sprintf('%02d:%d~ %s',
     @mode == 24 ? now.hour : now.hour % 12,
     now.min / 10,
     @mode != 24 ? now.hour / 12 == 1 ? 'pm' : 'am' : ''
   )
 end

 def update
   @time = Time.now + @offset
 end

 def actual
   @time
 end

 # def advance(amt)
 def +(amt)
   @time = @time + amt
   self
 end

 def -(amt)
   @time = @time + (-amt)
   # reset the minimum displayed time
   @mintime = Time.at(@time.to_i - @variance).to_i
   self
 end
end

if __FILE__ == $0 then
 t = FuzzyTime.new
 t.mode = 24

 30.times {
   t += 60
   puts "#{t.to_s} (#{t.actual.strftime('%H:%M')})"
 }
end
