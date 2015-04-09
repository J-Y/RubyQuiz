class ProgramManager
 DAYS = %w(sun mon tue wed thu fri sat)

 def initialize
   @recurring = Hash.new{|h,k| h[k] = []}
   @concrete = []
 end

 def add(o)
   case o[:start]
   when Fixnum:
     o[:days].each do |day|
       @recurring[DAYS.index(day)] << [o[:start]..o[:end], o[:channel]]
     end
   when Time:
     @concrete.unshift [o[:start]..o[:end], o[:channel]]
   end
 end

 def record?(time)
   @concrete.each do |times, channel|
     return channel if times.include? time
   end

   time_s = (time.hour*60 + time.min)*60 + time.sec
   @recurring.each do |day, programs|
     next unless day == time.wday
     programs.each do |times, channel|
       return channel if times.include? time_s
     end
   end
   nil
 end
end
