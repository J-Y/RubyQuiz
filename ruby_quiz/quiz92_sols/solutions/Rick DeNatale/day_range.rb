# This class was written as an answer to RubyQuiz92.
#
# The DayRange.new method takes one or more day specifications as either integers or natural language
# strings representing day names.  An instance will respond to to_s with a string representing
# the list of days with consecutive days collapsed to a form like 'Mon-Fri'
#
# Several methods take "Rails-style" options, one or more associations after any normal parameters.
# The keys of these associations can be Strings or symbols which will be converted using to_sym.
#
# Features not called for in the quiz include:
#   
#   * A number for the start of the week may be specified.  This will affect the output of
#     to_s. For example, :week_start => 7, indicates that the week starts on Sunday, and
#        DayRange.new('Sat', 'Sun', 'Mon', :week_start => 7).to_s => "Sun-Mon, Sat"
#
#   * Support is provided for languages other than English, French is built in, but additional
#     languages can be added, either on the new call, or by a class method DayRange.add_language 
#
#   * DayRanges are enumerable and produce the numbers of the day they contain, in Monday-Sunday
#     order.
#
#   * Two Dayranges are == if they contain the same days
#   
# Author: Rick DeNatale  http://talklikeaduck.denhaven2.com
#
# Test cases are in the file testdayrange.rb
#
# The code which does most of the work in detecting sub-ranges is in the file subranges.rb
# This adds a method to Enumerable which produces an array of ranges which cover the same contents
# as the Enumeration.  

require 'subranges'
# 
class DayRange

	include Enumerable

	# StringSymHash extends Hash so that symbol and string keys are equivalent a la Rails
	# Normally I don't like implementing things like this via sub-classing but...
	class StringSymHash < Hash

		def [](key)
			super(key.to_sym)
		end

		def []=(key,value)
			super(key.to_sym, value)
		end

		def StringSymHash.[](hash)
			ssh = StringSymHash.new
			hash.each { |k, v| ssh[k] = v}
			ssh
		end
	end

	# maps and names for English and French
	@@day_maps = StringSymHash[ :English =>  { 
                                             'Monday' => 1, 'Mon' => 1, 'Tuesday' => 2, 'Tue' => 2,
		                             'Wednesday' => 3, 'Wed' => 3, 'Thursday' => 4, 'Thu' => 4,
		                             'Friday' => 5, 'Fri' => 5, 'Saturday' => 6, 'Sat' => 6,
		                             'Sunday' => 7, 'Sun' => 7 }, 
				     :French => { 
                                             'Lundi' => 1, 'Lun' => 1, 'Mardi' => 2, 'Mar' => 2,
		                             'Mercredi' => 3, 'Mer' => 3, 'Jeudi' => 4, 'Jeu' => 4,
		                             'Vendredi' => 5, 'Ven' => 5, 'Samedi' => 6, 'Sam' => 6,
		                             'Dimanche' => 7, 'Dim' => 7 } ]
	@@day_names = StringSymHash[	
		:English => [nil, 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
		:French => [nil, 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
	]

	# Add a language to those supported by the DayRange class
	#
	# :call-seq:
	#    DayRange.add_language(lang_name, day_map[, day_names])
	#
	# The <em>lang_name_ parameter</em> is the name of the language. It will be internally converted
	# to a symbol. So, for example, if you have:
	#
	#     DayRange.add_language('Esperanto', ...)
	#
	# then one could ask for a DayRange in Esperanto with:
	#     
	#     DayRange.new(1, 3, :Language => :Esperanto)
	#     
	# The <em>day_map</em> parameter should be a Hash which maps day names to integers in 
	# the range (1..7).  More than one name may map to a particular day_number.
	#
	# The _day_names_ parameter must be duck-typeable to a 7-element array or Strings, with the
	# first element containing the name which will be used for Monday for output (e.g. for to_s),
	# and the last for Sunday.
	#
	# If _day_names_ is omitted, then it will be constructed by finding a name for each day_number
	# as least as short as any other name which maps to that day_number in _day_map_
	def DayRange.add_language(lang_name, day_map, day_names = nil)
		#HACK - if user supplied day_names pre-pend an element so that we can use
		# pseudo 1-origin indexing

		day_names = day_names.dup.unshift('') if day_names
		@@day_names[lang_name.to_s] = validated_day_names(day_names || day_names_from_day_map(day_map))
		@@day_maps[lang_name.to_s] = day_map.dup
	end

	# Remove the language _lang_name_
	# Do nothing silently if _lang_name_ is not present
	#
	# :call-seq:
	#    DayRange.remove_language(lang_name)
	#
	def DayRange.remove_language(lang_name)
		@@day_names.delete(lang_name)
		@@day_maps.delete(lang_name)
	end

	def DayRange.day_names_from_day_map(day_map) #:nodoc:
		# set each days name to the shortest name
		# in the name mapping
		# puts("Debug- DayRange.day_names_from_day_map(#{day_map})")
		day_names = Array.new(8)
		day_map.each do |name ,number|
			current_name = day_names[number] || day_names[number] = name
			day_names[number] = name if name.length < current_name.length
		end
		validated_day_names(day_names)
	end

	def DayRange.validated_day_names(day_names) #:nodoc:
		(1..7).each do |i|
			check_arg(day_names[i], "No name for day number #{i}")
		end
		day_names
	end

	def DayRange.check_arg(assertion, msg) # :nodoc:
		raise ArgumentError.new( msg) unless assertion
	end

	def DayRange.day_names_from_options(options, day_map) # :nodoc:
		# puts "Debug- DayRange.day_names_from_options(options=#{options.inspect},"
		# puts " day_map=#{day_map.inspect})"
		return options[:day_names] if options.key?(:day_names)
		return DayRange.day_names_from_day_map(day_map)
	end

	def DayRange.language_from_options(options) # :nodoc:
		get_option(:language, options, :English)
	end

	def DayRange.get_option(option, options, default) # :nodoc:
		options.key?(option) ? options[option] : default
	end

	# Returns a new DayRange (which contains one or more days of the week)
	#
	# :call-seq:
	#     DayRange.new(day* [, options])
	#
	# <em>day</em> arguments can be either numbers in the range
	# (1..7) or names in the <em>day_mapping</em> (see <b>:day_mapping</b> option).
	#
	# Options:
	#
	# [*:language* => symbol] Specifies the language to be used to
	# interpret the _day_s which are Strings, and for the default options for output via DayName#to_s
	# The possible values for the symbol are :English, and :French,
	# additional languages can be added via the DayRange.addLanguage 
	# method. If this option is not specified, :English will be used.
	# 
	# [*:day__map* => hash ] The value _hash_ should be a hash which maps the names
	# of days to the number of the day, with 1 being the first
	# day of the week (normally Monday), up to 7 for the last day 
	# of the week (normally Sunday).
	# More than one name may map to the same day. If not specified,
	# the day_mapping for the selected language is used.
	#
	# [*:day_names* => array] The value _array_ must be duck-typeable to a 7-element array.
	# The elements are the names of the days to be used by default for
	# output (e.g. with DayRange#to_s.  If not specified, then the day_names for the selected
	# language will be used, unless *:day_map* is specified in which case
	# *:day_names* will be computed from one of the sortest names in the map for each 
	# day.
	#
	# [*:week_start* => int]  The value _int_ must be in the range (1, 7). 
	# It is used to shift the start of the week. For example to create a
	# DayRange for a week which starts on Sunday rather than Monday,
	# specify a week_start of 7.  Although it is also possible to
	# achieve the same effect by changing the numbers in day_mapping,
	# using week_start allows the same day_mapping to be used for weeks
	# starting on different days. 
	#
	# [*:min_span* => int] The value _int_ indicates the minimum span of days which will
	# be collapsed into hyphenated form.  The default is 3, as specified by the Quiz spec
	# I missed this the first time.
	def initialize( *days ) #:doc:
		options = extract_options_from_args!(days)
		# puts "Debug: options = #{options.inspect}"
		@day_map = day_map_from_options(options)
		@day_map.each do |name, number|
			DayRange.check_arg((1..7) === number, 
                                           "'#{number}' is not an acceptable day for #{name.to_s}.")
		end
		@min_span = DayRange.get_option(:min_span, options, 3)
		@language = DayRange.language_from_options(options)
		@day_names = DayRange.day_names_from_options(options,@day_map)
		@week_start = week_start_from_options(options, @day_map)
		@day_numbers = days.map do | day |
			number = @day_map[day] || day
			DayRange.check_arg((1..7) === number, "'#{number.inspect}' is not an acceptable day.")
			number
		end
		@day_numbers.sort!
	end

	# Return an array of subranges of @day_numbers adjusted for the week_start
	def adjusted_ranges(min_span, week_start)
		(week_start == 1 ? @day_numbers : @day_numbers.map { |elem| ws_adj(elem,week_start) }).subranges(min_span)
	end

	# Two DayRanges are == if they contain the same day numbers
	def ==(other)
		false unless other.kind_of? DayRange
		self.to_a == other.to_a
	end
		

	# Call _block_ once for each day number in _day_range_ passing the day number to the block.
	# The order should be the same regardless of week start, i.e. Monday should always come first
	# then Tuesday, etc.
	# 
	# :call-seq:
	#       day_range.each {|day_number| block } -> _day_range_
	def each()
		@day_numbers.each { | elem | yield elem }
	end

	# Convert _day_range_ to an array, elements will be in order so that Monday, if it is the range
	# will be first then Tuesday, etc.  i.e. the effect of weekstart will be removed
	# :call-seq:
	#      day_range.to_a
	def to_a
		@day_numbers.dup
	end

	# Call _block_ once for each day name in _day_range_, passing that name to the block 
	#
	# :call-seq:
	#     day_range.each_name [(options)] { |day_name| block } -> _day_range_ 
	#
	# *Options*
	#
	# Options are specified Rails style, as one or more associations at the end of the argument
	# list.
	#
	# [*:language* => symbol] Specifies the language to be used for the names
	# The possible values for the _symbol_ are :English, and :French,
	# additional languages can be added via the DayRange.addLanguage 
	# method. If this option is not specified, :English will be used.
	# 
	# [*:day_names* => array] The _array_ must be 7-element array.
	# The elements are the names of the days to be used by default for
	# output via to_s.  If not specified, then the day_name for the selected
	# language will be used.
	#
	def each_name(options={})
		names = get_names_override(options)
		to_a.each { | day_number | yield names[day_number] }
	end

	def get_names_override(options)
		return options[:day_names].dup.unshift('') if options.key?(:day_names)
		language = options[:language]
		return @@day_names[language] if language
		@day_names
	end
		


	# Returns a string representing the DayRange, Options can be specified.
	#
	# :call-seq:
	#     day_range.to_s [(options)]
	#
	# Options:
	#
	# [*:language* => symbol] Specifies the language to be used for output
	# The possible values for _symbol_ are :English, and :French,
	# additional languages can be added via the DayRange.addLanguage 
	# method. If this option is not specified, the language used when the DayRange
	# was created  will be used.
	# 
	# [*:day_names* => array] The _array_ must be duck-typeable to a 7-element array.
	# The elements are the names of the days to be used by default for
	# output via to_s.  If not specified, then the day_names for the selected
	# language will be used.
	#
	# [*:min_span* => int] The value _int_ indicates the minimum span of days which will
	# be collapsed into hyphenated form.  The default is 3, as specified by the Quiz spec
	#
	# [*:week_start* => int]  The value _int_ must be in the range (1, 7). 
	#
	def to_s(options={})
		names = get_names_override(options)
		#puts "Debug: @day_names=#{@day_names.inspect}, names=#{names}"
		min_span = DayRange.get_option(:min_span, options, @min_span)
		week_start = DayRange.get_option(:week_start, options, @week_start)
	
		result = ""
		adjusted_ranges(min_span,week_start).map {|range| 
			range.first == range.last ?  
                               "#{names[ws_unadj(range.first, week_start)]}" : 
			       "#{names[ws_unadj(range.first, week_start)]}-#{names[ws_unadj(range.last,week_start)]}"
		}.join(", ")
	end

	private
        # convert a number where 1 = Mon.. 7 = Sunday to the equivalent
	# when the week starts on day number
	def ws_adj(number, week_start)
		((number - week_start) % 7) + 1
	end
	
	# convert a number back to the original form
	def ws_unadj(number, week_start)
		((number + week_start + 5) % 7) + 1
	end

	def extract_options_from_args!(args)
		#puts "Debug - extract_options_from_args!(#{args.inspect})"
		#puts "       #{args.last.class}"
		StringSymHash[args.last.kind_of?(Hash) ? args.pop : {}]
	end

	def day_map_from_options(options)
		#puts "Debug: language=#{DayRange.language_from_options(options)}"
	        #puts "	map=#{@@day_maps[DayRange.language_from_options(options)]}"
		DayRange.get_option(:day_map, options, @@day_maps[DayRange.language_from_options(options)])
	end

	def week_start_from_options(options, day_map)
		week_start = DayRange.get_option(:week_start, options, 1)
		week_start = day_map[week_start] || week_start
		DayRange.check_arg((1..7) === week_start,":week_start must be in the range (1..7)")
		week_start
	end

end
