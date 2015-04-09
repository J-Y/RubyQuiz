#!/usr/bin/ruby
#
# Submission for RubyQuiz #144 - Time Window
# http://www.rubyquiz.com/quiz144.html
#
# Kaushik Sridharan <skaushik (at) hotmail (dot) com>
# 20-Oct-2007
#


class TimeWindow

	#
	# Rule is a helper class used by TimeWindow. Each rule
	# instance represents one of the semicolon-separated
	# segments in the time window specification.
	# 
	# A Rule object maintains a day range and a time range
	# against which it checks the input. The day range is
	# simply an array of booleans for every day of the week.
	# The time range is a Range object with the bounds defined
	# as seconds within a day. If either the day range or the
	# time range is not provided, it defaults to the entire
	# week and entire day respectively.
	# 
	# A time value is said to match a rule when it satisfies
	# the day range and the time range.
	# 
	class Rule

		DAYS = %w(sun mon tue wed thu fri sat)

		# Initialize a rule. The str parameter is a single segment 
		# of the range specification.
		# Examples: "Sat-Sun"
		#           "Mon Wed 0700-0900"
		def initialize(str)
			@day_range = []
			@time_ranges = []

			str.split.each do |seg|
				if seg =~ /^([A-Za-z]+)-?([A-Za-z]*)/
					from = DAYS.index($1.downcase)
					to = DAYS.index($2.downcase) || from
					throw "Invalid day" if !from or !to
					begin
						@day_range[from] = true
						from = (from + 1) % 7
					end while from != (to + 1) % 7
				elsif seg =~/^(\d+)-?(\d*)/
					from, to = $1.to_i, ($2 || $1).to_i
					from_min = (from / 100) * 3600 + (from % 100)
					to_min = (to / 100) * 3600 + (to % 100)
					@time_ranges << (from_min ... to_min)
				end
			end

			@day_range = [true] * 7 if @day_range.empty?
			@time_ranges << (0 ... (24 * 60 * 60)) if @time_ranges.empty?
		end

		# Return true if the time object falls within the interval
		# defined by this rule.
		def include?(time)
			return false if not @day_range[time.wday]
			secs = time.hour * 60 * 60 + time.min * 60 + time.sec
			@time_ranges.each do |r|
				return true if r.include?(secs)
			end
			return false
		end

	end

	# Initialize the time range. The str parameter is a sequence
	# of semi-colon separated rules. Also handle the case
	# that an empty string means all the time.
	# Example: "Sat-Sun; Mon Wed 0700-0900; Thu 0700-0900 1000-1200"
	def initialize(str)
		@rules = str.split(";").collect { |seg| Rule.new(seg) }
	   	@rules << Rule.new("") if @rules.empty?
	end

	# Return true if at least one rule matches the given time.
	def include?(time)
		@rules.each do |rule|
			return true if rule.include?(time)
		end
		return false
	end

end


