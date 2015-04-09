class Time
	def seconds
		(hour * 60 + min) * 60 + sec
	end
end

class Program
	attr_reader :channel

	def initialize(program_details)
		@program_start = program_details[:start]
		@program_end = program_details[:end]
		@channel = program_details[:channel]
	end
end

class SpecificProgram < Program
	def record?(time)
		time.between?(@program_start, @program_end)
	end
end

class RepeatingProgram < Program
	WEEKDAYS = %w(mon tue wed thu fri sat sun)

	def initialize(program_details)
		super
		@days = program_details[:days].map {|day| WEEKDAYS.index(day) + 1}
	end

	def record?(time)
		@days.include?(time.wday) && time.seconds.between?(@program_start, @program_end)
	end
end

class ProgramManager
	def initialize()
		@programs = []
	end

	def add(program_details)
		case program_details[:start]
		when Numeric
			@programs << RepeatingProgram.new(program_details)
		when Time
			@programs[0, 0] = SpecificProgram.new(program_details)
		end

		self
	end

	def record?(time)
		program = @programs.find {|program| program.record?(time)}
		program ? program.channel : nil
	end
end
