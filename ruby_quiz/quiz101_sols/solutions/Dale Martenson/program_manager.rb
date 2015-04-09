class Program
  attr_accessor :start_time, :end_time, :channel, :days

  def initialize( program_details )
    @start_time = program_details[:start]
    @end_time = program_details[:end]
    @channel = program_details[:channel]
    @days = program_details[:days]
  end
end

class ProgramManager
  def initialize
    @programs = []
  end

  def record?(time)
    @programs.reverse.each do |p|
      if p.days.nil?
        # specific program
        if (p.start_time..p.end_time).include?(time)
          return p.channel
        end
      else
        # repeating program
        weekday = %w( sun mon tue wed thu fri sat )[time.wday]
        time_of_day = (time.hour * 3600) + (time.min * 60) + time.sec
        if p.days.include?(weekday) && (p.start_time..p.end_time).include?(time_of_day)
          return p.channel
        end
      end
    end

    return nil
  end

  def add(program_details)
    @programs << Program.new( program_details )
  end
end
