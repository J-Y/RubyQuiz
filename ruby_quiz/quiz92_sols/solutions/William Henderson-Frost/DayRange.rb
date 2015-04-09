# William Henderson-Frost
# Ruby Quiz 92

class DayRange
  
  Days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  def initialize(*args)
    @days = []
    args.each do |arg|
      raise ArgumentError unless (Days.include?(arg) or (1..7).include?(arg))
    end
    (0..6).each do |i|
      if args.include?(i+1) or args.include?(Days[i]) or args.include?(Days[i+7])
        @days.push(i)
      end
    end
  end
  
  def to_s()
    print_days, i = [], 0
    while i < 7
      7.downto(i+2) do |x|
        if @days & (i..x).to_a == (i..x).to_a
          print_days.push(Days[i] << "-" << Days[x])
          i = x + 1
          break
        end
      end
      print_days.push(Days[i]) if @days.include?(i)
      i += 1
    end
    return print_days.join(", ")
  end
  
end


puts DayRange.new('Wed', 5, 2, 1, 7, 'Saturday').to_s
