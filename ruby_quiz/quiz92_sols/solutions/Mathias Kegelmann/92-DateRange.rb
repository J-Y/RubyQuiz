module Enumerable
  # Divide the Enumerable into arrays of "runs".  A run is a sequence of
  # consecutive elements, in the sense of "succ".
  # If a block is given, then  the methods acts as an iterator,
  # otherwise it returns an array of run arrays.
  def runs
    unless block_given?
      a = []
      runs { |x| a << x }
      return a
    end

    current = []
    each do |x|
      if current.empty? || current.last.succ == x 
        current << x
      else
        yield current
        current = [x]
      end
    end
    yield current unless current.empty?
  end
end


class DateRange
  @@days = %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday}
  @@map = { }
  @@days.each_with_index do |d, i|
    i += 1
    @@map[d] = i
    @@map[d[0...3]] = i
    @@map[i] = i
  end

  def self.day_to_i(day)
    raise ArgumentError.new(day.to_s) unless result = @@map[day]
    return result
  end

  def self.i_to_s(n)
    raise ArgumentError.new(n.to_s) unless (1..7) === n
    @@days[n - 1][0...3]
  end

  def initialize(*days)
    @days = days.collect{|d| DateRange.day_to_i(d)}.sort.uniq
  end

  def to_s
    @days.runs.collect do |a|
      from = DateRange.i_to_s(a.first)
      till = DateRange.i_to_s(a.last)
      case a.size
      when 1 then from
      when 2 then from + ", " + till
      else from + "-" + till
      end
    end.join(", ")
  end

end
