class DayRange
  SHORT_NAMES = %w[Mon Tue Wed Thu Fri Sat Sun].freeze
  LONG_NAMES  = %w[ Monday
                    Tuesday
                    Wednesday
                    Thursday
                    Friday
                    Saturday
                    Sunday ].freeze
  
  def initialize(*days)
    @days = days.map do |d|
      ds = d.to_s.downcase.capitalize
      SHORT_NAMES.index(ds) || LONG_NAMES.index(ds) || d - 1
    end rescue raise(ArgumentError, "Unrecognized number format.")
    unless @days.all? { |d| d.between?(0, 6) }
      raise ArgumentError, "Days must be between 1 and 7."
    end
    raise ArgumentError, "Duplicate days given." unless @days == @days.uniq
  end
  
  def to_s(names = SHORT_NAMES)
    raise ArgumentError, "Please pass seven day names." unless names.size == 7
    
    @days.inject(Array.new) do |groups, day|
      if groups.empty? or groups.last.last.succ != day
        groups << [day]
      else
        groups.last << day
        groups
      end
    end.map { |g| g.size > 2 ? "#{g.first}-#{g.last}" : g.join(", ") }.
        join(", ").gsub(/\d/) { |i| names[i.to_i] }
  end
end
