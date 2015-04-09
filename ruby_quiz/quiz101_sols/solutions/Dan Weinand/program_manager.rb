class ProgramManager
 # Query to determine if we should be recording at any particular
 # moment. It can be assumed that the VCR will query the program
 # manager at most twice per minute, and with always increasing minutes.
 # New programs may be added between two calls to #record?.
 #
 # This method must return either a +nil+, indicating to stop recording,
 # or don't start, or an +Integer+, which is the channel number we should
 # be recording.
 def record?(time)
   secs = convert_to_secs(time)
   specific_programs = @programs.select {|p| p.specific? && p.starts_at <= time && p.ends_at >= time}
   weekly_programs = @programs.select {|p| p.weekly? && p.starts_at <= secs && p.ends_at >= secs && p.days.include?(time.strftime("%a")) }
   if !specific_programs.empty?
     specific_programs.last.channel
   elsif !weekly_programs.empty?
     weekly_programs.last.channel
   end
 end

 # Adds a new Program to the list of programs to record.
 def add(program_details)
   @programs ||= []
   program = Program.new
   program.starts_at = program_details[:start].is_a?(Time) ? program_details[:start] : program_details[:start].to_i
   program.ends_at = program_details[:end].is_a?(Time) ? program_details[:end] : program_details[:end].to_i
   program.channel = program_details[:channel].to_i
   program.days = program_details[:days] ? program_details[:days].collect {|d| d.capitalize} : []
   @programs << program
 end

 protected

 # Converts a time object to the number of seconds since midnight
 def convert_to_secs(time)
   ((time.hour*60)*60) + (time.min*60) + time.sec
 end
end
