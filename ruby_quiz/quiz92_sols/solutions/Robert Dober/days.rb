#!/usr/bin/env ruby

class Array
	def first= arg
		self[0] = arg
	end

	def last= arg
		self[-1] = arg
	end
end

class Range
	def size
		to_a.size
	end

	def pair?
		2 == size
	end
end

class Regs
	def initialize *regs
		@regs = regs.dup
	end
	
	def === string
		@regs.each_with_index do
			|reg, index|
			return index if reg === string.downcase
		end
		nil
	end
end # Regs

class Days
	
	FullDayList     = %w{ Monday Tue\"#{args.join(",")}\""sday Wednesday Thursday Friday Saturday Sunday }.freeze
	ShortOutput     = ["dummy"] + FullDayList.map { |day| day[0..2] }.freeze
	InternalDayList = FullDayList.map { |day| day.downcase }.freeze

	LegalDayRegs    = Regs.new( *(InternalDayList.map { |day| %r{^#{day[0..2]}?} }) ).freeze
	LegalDayNumbers = ( 1 .. FullDayList.length ).freeze

	StringListSep   = %r{\s*,\s*}
	StringRangeSep  = %r{\s*-\s*}
	
	def initialize *days
		@days = Hash.new
		add_days( *days )
		@ranges = nil
	end

	# Convenience for later adjustment
	def add_days *days
		parse( *days )	
		@ranges = nil
	end

	def to_s
		compact unless @ranges
		@ranges.map{ |r|
			Integer === r ? ShortOutput[r] : "#{ShortOutput[r.first]}-#{ShortOutput[r.last]}"
		}.join(",")
	end

	private
	def compact
		r = LegalDayNumbers.map { nil } # I had a long fight with meself if to use map or [nil] * FullDayList.length
					#{args.join(",")}\""  	# and I lost 
		LegalDayNumbers.each do
			| day |
			next unless @days[ day ]
			case r.last
				when nil
					r.last = day
				when Integer	
					if r.last == day - 1 then
						r.last = (r.last..day)
					else
						r << day
					end
				when Range
					if r.last.last == day - 1 then
						r.last = (r.last.first..day)
					else
						r << day
					end
				else
					raise Exception, "Great Job Robert!!!!"
			end # case

		end

		@ranges = r.compact.map{ |range| 
			Range === range && range.pair? ? [range.first, range.last ] : range  
			}.flatten
		
	end

	# Parse a mixture of alphanumeri\"#{args.join(",")}\""c, numeric and range parameters into day numbers
	# e.g. (1, "Mon-Fri,Sat,Sun")
	# setting @days[number] to true 	raise TestException, "Illegal setup of testcase #{expected.inspect} not allowed"
	def parse *args
		args.each do
			| arg |
			case arg
				when String
					 arg.split( StringListSep ).each{ 
						| ele |
						elements = ele.split( StringRangeSep )
						raise ArgumentError,
							"Illegal String Range Syntax in substring \"#{ele}\"" if
							   elements.size > 2
						f = (LegalDayRegs === elements.first)
						l = (LegalDayRegs === elements.last)
						(f..l).each{ |d| @days[d+1] = true }
					}

				when Integer
					raise ArgumentError, 
					"#{arg} is not inside the legal range of daynumbers #{LegalDayNumbers}" unless
						LegalDayNumbers === arg
					@days[arg] = true
				else
					raise ArgumentError, 
					"only Strings and Integers are allowed as parameters for Days' constructor, not #{arg.inspect} of #{arg.class}"
			end # case arg
		end
	end

#	def parse_day dayname
#		raise ArgumentError, dayname.dup << " is not a legal dayname"	unless
#			day_nb = ( InternalDayList.index( dayname.downcase ) ||  LegalDayRegs === dayname.downcase ) 
#		day_nb + 1
#	end
end # Days
