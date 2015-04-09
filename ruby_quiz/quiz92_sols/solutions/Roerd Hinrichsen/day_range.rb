require "date"

# class DayRange represents selected days of a week.
class DayRange

    ABBREVIATIONS = Date::ABBR_DAYNAMES

    FULL_NAMES = Date::DAYNAMES

    # Initialize a new DayRange.
    # Takes an array of day ids, which are either numbers (1-7),
    # three-letter abbreviations or full week-day names,
    # and optionally an array of output day names, starting with Sunday.
    def initialize list, names = ABBREVIATIONS
        @names = names
        @list = []
        list.each { |day|
            if day.class == Fixnum and 1 <= day and day <= 7
                @list << day
            elsif day.class == String and
                idx = ABBREVIATIONS.index(day) || FULL_NAMES.index(day)
                if idx == 0 then idx = 7 end
                @list << idx
            else
                raise ArgumentError, "#{day} is not a valid day id."
            end
        }
        @list.uniq!
        @list.sort!
    end

    # Return a string representation of the DayRange.
    # The representation is a comma-seperated list of output day names.
    # If more than two days are adjacent, they are represented by a range.
    def to_s
        list = to_a
        result = []
        while day = list.shift
            next_day = day + 1
            while list.first == next_day
                list.shift
                next_day += 1
            end
            if next_day <= day + 2
                result << @names[day % 7]
                if next_day == day + 2
                    result << @names[(day+1) % 7]
                end
            else
                result << (@names[day % 7] + "-" +
                           @names[(next_day-1) % 7])
            end
        end
        result.join ", "
    end

    # Return an array of the selected days of the week,
    # represented by numbers (1-7).
    def to_a
        @list.clone
    end

end
