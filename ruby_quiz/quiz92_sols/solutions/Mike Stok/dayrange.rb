class DayRange
  
  # Class for translating between day names and numbers
  class DayTranslator
    require 'abbrev'
    VALID_DAY_NUMBERS = 1 .. 7
    
    def initialize(day_names=%w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday })
      day_names.size == 7 or raise ArgumentError, "must have a 7 element array"
      # are there 7 different names?
      @day_names = day_names
      @name_map = Abbrev::abbrev(day_names)
      @number_map = {}
      day_names.each_with_index do |name, i|
        @number_map[name] = i + 1
      end
    end
    
    # Convert a string (day name or abbreviation) or a number to a day number and
    # return it.
    #
    # If we get invalid input then raise an ArgumentError
    def make_number(number_or_string)
      number = case number_or_string
        when String
          @number_map[@name_map[number_or_string]]
        when Numeric
          number_or_string.to_i
        else 
          raise ArgumentError
        end
      valid_day_number?(number) or raise ArgumentError
      number  
    end
    
    # Turn a day number into a string whose length may be specified
    def make_string(number, length=3)
      valid_day_number?(number) or raise ArgumentError
      name = @day_names[number - 1]
      name[0 ... [name.length, length].min]
    end
        
    def valid_day_number?(num)
      VALID_DAY_NUMBERS.include?(num)
    end
  end
  
  MIN_RANGE_SIZE = 3  # Ranges smaller than this are output as individual items
  
  def initialize(*day_list)
    @translator = DayRange::DayTranslator.new
    @day_ranges = make_ranges(day_list.collect { |day| @translator.make_number(day) })
  end
  
  # 
  def to_s
    @day_ranges.collect { |range|
      if range.size < MIN_RANGE_SIZE
        range.collect { |day_num| @translator.make_string(day_num) }
      else 
        "#{@translator.make_string(range.first)}-#{@translator.make_string(range.last)}"
      end
    }.flatten.join(', ')
  end
  
  # Turn a list of day numbers into a list of "ranges."
  # 
  # Each range is stored as an array because it's easier to add elements to an
  # array, and we are only dealing with 7 days at most here.
  def make_ranges(day_list)
    day_list.sort.inject([]) { |ranges, day_num|
      if ranges.empty? or day_num != ranges.last.last.succ
        ranges << [day_num]
      else
        ranges.last << day_num
      end
      ranges
    }
  end
end