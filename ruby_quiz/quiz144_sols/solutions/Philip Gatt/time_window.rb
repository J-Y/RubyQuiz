class TimeWindow
  def initialize(definition_string)
    @ranges = []
    definition_string.split(/;/).each do |part|
      @ranges << Range.create_from_string(part.strip)
    end
    @ranges << Range.create_from_string('') if @ranges.empty?
  end

  def include?(time)
    @ranges.any?  {|r| r.include?(time)}
  end

  class Range < Struct.new(:day_parts, :time_parts)
    DAYS = %w{Sun Mon Tue Wed Thu Fri Sat}

    def self.create_from_string(str)
      time_parts = []
      day_parts = []
      str.split(/ /).each do |token|
        token.strip!
        if DAYS.include?(token)
          day_parts << token
        elsif token =~ /^(\w{3})-(\w{3})$/
          start_day, end_day = $1, $2
          start_found = false
          (DAYS * 2).each do |d|
            start_found = true if d == start_day
            day_parts << d if start_found
            break if d == end_day && start_found
          end
        elsif token =~ /^(\d{4})-(\d{4})$/
          time_parts << (($1.to_i)..($2.to_i - 1))
        else
          raise "Unrecognized token: #{token}"
        end
      end
      time_parts << (0..2399) if time_parts.empty?
      day_parts = DAYS.clone if day_parts.empty?
      self.new(day_parts, time_parts)
    end

    def include?(time)
      matches_day?(time) && matches_minute?(time)
    end

    def matches_day?(time)
      day = time.strftime('%a')
      self.day_parts.include?(day)
    end

    def matches_minute?(time)
      minute = time.strftime('%H%M').to_i
      self.time_parts.any?  {|tp| tp.include?(minute) }
    end
  end
end
