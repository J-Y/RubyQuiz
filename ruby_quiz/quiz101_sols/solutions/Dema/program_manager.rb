require 'core_ext'
require 'program'

class ProgramManager

  def initialize
    @programs = []
  end

  # Query to determine if we should be recording at any particular
  # moment.  It can be assumed that the VCR will query the program
  # manager at most twice per minute, and with always increasing minutes.
  # New programs may be added between two calls to #record?.
  #
  # This method must return either a +nil+, indicating to stop recording,
  # or don't start, or an +Integer+, which is the channel number we should
  # be recording.
  def record?(time)
    candidates = @programs.select { |p| p.on?(time)  }
    weekly, specific = candidates.partition { |p| p.weekly?  }
    return specific.last.channel unless specific.empty?
    return weekly.last.channel unless weekly.empty?
    nil
  end

  # Adds a new Program to the list of programs to record.
  def add(program)
    @programs << Program.new(program)
  end

end
