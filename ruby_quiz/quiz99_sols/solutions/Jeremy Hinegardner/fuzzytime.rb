#----------------------------------------------------------------------
# Ruby Quiz #99 - Fuzzy Time
#
# Jeremy Hinegardner
#----------------------------------------------------------------------
class FuzzyTime

    HOUR_24_FORMAT  = "%H:%M"
    HOUR_12_FORMAT  = "%I:%M"

    HOUR_FORMAT_OPTIONS = Hash.new(HOUR_24_FORMAT)
    HOUR_FORMAT_OPTIONS[HOUR_12_FORMAT]     = HOUR_12_FORMAT
    HOUR_FORMAT_OPTIONS[:twelve_hour]       = HOUR_12_FORMAT
    HOUR_FORMAT_OPTIONS[HOUR_24_FORMAT]     = HOUR_24_FORMAT
    HOUR_FORMAT_OPTIONS[:twentyfour_hour]   = HOUR_24_FORMAT
    
    GRANULARITIES = [:one_minute, :ten_minute, :one_hour]

    attr_accessor :time_format
    attr_accessor :fuzz_factor
    attr_accessor :display_granularity

    attr_reader   :actual
    attr_reader   :fuzzed
    attr_reader   :display

    def initialize(time = Time.now)
        @actual              = time.dup
        @time_format         = HOUR_24_FORMAT
        @fuzz_factor         = 5 * 60
        @display_granularity = :ten_minute

        # initialize a base history that is minimal to give maximum
        # range for calculating a fuzzy time
        @fuzzed         = @actual - @fuzz_factor
        @fuzz_history   = [ { :actual => @actual, :fuzzed => @fuzzed, :display => calculate_display_time } ]
        calculate_fuzz_time
    end

    def advance(seconds)
        @actual += seconds
        calculate_fuzz_time
    end

    def update
        @actual = Time.now
        calculate_fuzz_time
    end

    # return a string representation of the display time which is the time
    # with up to the @disiplay_granularity replaced by '~'.  when
    # :one_minute is the granularity, nothing needs to be done
    def to_s
        s = @display.strftime(time_format)
        case @display_granularity
        when :ten_minute
            s.chop!
            s << "~"
        when :one_hour
            s.chop!
            s.chop!
            s << "~~"
        end
        return s
    end

    # allow the time format to be set to 24 hour or 12 hour time
    def time_format=(format)
        @time_format = HOUR_FORMAT_OPTIONS[format]
    end

    # all the fuzz factor to be set in a range of minutes, no limit
    def fuzz_factor=(minutes)
        @fuzz_factor = 60 * minutes.abs
    end

    def fuzz_factor
        (@fuzz_factor / 60).to_i
    end

    def display_granularity=(granularity)
        if GRANULARITIES.include?(granularity.to_sym) 
            @display_granularity = granularity
            # need to recalculate this when the granularity is updated 
            calculate_display_time
        else
            raise ArgumentError, "display_granularity must be one of #{GRANULARITIES.join(",")}"
        end
        @display_granularity
    end
    
    private

    #
    # the display time is the fuzzy time converted to a "floor" time
    # with a granularity base upon the @display_granularity.  For
    # example, if the fuzzed time is 13:43 then the display time would
    # be:
    #
    #   granularity     display
    #   ========================
    #   :one_minute     13:43
    #   :ten_minute     13:40
    #   :one_hour       13:00
    #
    def calculate_display_time
        case @display_granularity
        when :one_minute 
            min = @fuzzed.min
        when :ten_minute
            min = (@fuzzed.min / 10) * 10
        when :one_hour
            min = 0
        end

        @display = Time.mktime( @fuzzed.year, @fuzzed.month, @fuzzed.day, @fuzzed.hour, min, 0, 0)
    end

    #
    # calculate the new fuzzy time.
    #
    # Since :
    #   1) the displayed time must appear to be continually increasing
    #   2) we must always be within the fuzz factor of the actual time
    #
    # Therefore:
    #   the lower bound of the fuzzy range is the maximum of the displayed
    #   time or the lower bond of the fuzz factor around the actual time.
    #
    def calculate_fuzz_time
        last_display    = @fuzz_history.last[:display]
        min_fuzz_factor = @actual - @fuzz_factor
        lower_bound = last_display > min_fuzz_factor ? last_display : min_fuzz_factor

        upper_bound = @actual + @fuzz_factor

        range       = upper_bound - lower_bound
        @fuzzed     = lower_bound + rand(range + 1)
        calculate_display_time
        @fuzz_history << { :actual => @actual, :fuzzed => @fuzzed, :display => @display } 
    end

end
