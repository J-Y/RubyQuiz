class ProgramManager
 def initialize
   @programs = Array.new
 end

 def add(program)
   @programs << program
 end

 def record?(time)
   candidates = @programs.select {|program| program.include?(time)}
   return nil if candidates.empty?
   return candidates.first.channel if candidates.size == 1
   candidates.sort_by {|candidate| candidate.specificity}.last.channel
 end
end

class Program
 WEEKDAY_NAMES = %w(sun mon tue wed thu fri sat).freeze

 attr_reader :options

 def initialize(options)
   @options = options.dup
 end

 def include?(time)
   if options[:start].respond_to?(:strftime) then
     (options[:start] .. options[:end]).include?(time)
   else
     return false unless self.time?(time)
     return false unless self.day?(time)
     true
   end
 end

 def channel
   options[:channel]
 end

 def specificity
   return 2 if options[:start].respond_to?(:strftime)
   1
 end

 protected
 def time?(time)
   start = time - time.at_midnight
   (options[:start] .. options[:end]).include?(start)
 end

 def day?(time)
   options[:days].include?(WEEKDAY_NAMES[time.wday])
 end
end
