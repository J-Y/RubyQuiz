class Array

  def collapse_ranges(options = {})
        range = []
        return_array = []
        self.each_with_index do |item, i|
            range.push(item)
           # if this is the last item
            # - or -
            # there is another item after this one
            if item == self.last || self[i + 1]
                # if this is the last item
                # - or -
                # the next item is not the item after the current one
                 if item == self.last|| item.succ != self[i + 1]
                    # if there is a range of 3 items or more
                    if range.length >= 3
                        return_array.push(range.first..range.last)
                    # else empty the range individually
                    else
                        return_array.concat range
                    end
                    # clear out the range
                    range.clear
                end
            end
        end

        return return_array
    end

  def to_s
    self.map { |i| i.to_s }.join(', ')
  end
end

class Range
  def to_s
    "#{first}-#{last}"
  end
end

require 'date'

class Day < Date

  Days = [nil, "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  Abbr = [nil, "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  def self.commercial(int)
   day = send("from_#{int.class}".downcase.intern, int)
   super(1984,1,day)
  end

  def succ
    if cwday == 7
      Day.commercial(1)
    else
      super
    end
  end

  def to_s
    Days[cwday]
  end

  def to_abbr
    Abbr[cwday]
  end

  alias_method :to_s, :to_abbr

  def self.from_string(string)
    # If string isn't in Days or Abbr, return string and let Date#commercial raise ArgumentError
    Days.index(string.capitalize) || Abbr.index(string.capitalize) || string.capitalize
  end

  def self.from_fixnum(int)
    # Date#commercial allows integers over 7, so raise ArgumentErrror here
    if (1..7).include? int 
      int 
    else
      raise ArgumentError
    end
  end

end

class DayRange

  def initialize(array)
    @array = array.map{|i| Day.commercial(i) }.collapse_ranges
  end

  def to_s
    @array.to_s
  end

end
