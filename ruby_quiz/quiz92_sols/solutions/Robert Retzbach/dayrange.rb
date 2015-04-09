class DayRange
  def initialize day_list, day_labels = %w{Mo Di Mi Do Fr Sa So}
    raise 'need num(1-7) array' unless day_list.is_a? Array and
    day_list.all?{ |n| (1..7) === n.to_i }
    @day_list   = day_list.map   { |num| num.to_i }.uniq.sort

    raise 'need array of seven day labels' unless day_labels.is_a? Array and
    day_labels.size == 7
    @day_labels = day_labels.map { |day_label| day_label.to_s }
  end

  def to_s
    result        = Array.new
    current_range = [@day_list.first]

    (@day_list[1..-1] + [nil]).each do |day|
      if day == current_range.last.succ
        current_range << day
      else
        if current_range.size > 3
          result << [@day_labels[current_range.first - 1],
            @day_labels[current_range.last  - 1]].join('-')
        else
          result << current_range.map{ |d| @day_labels[d - 1] }
        end
        current_range = [day]
      end
    end
    result.join(', ')
  end
end

if __FILE__ == $0
  dayrange = DayRange.new [1,3,4,5,6,7], %w{Mo Di Mi Do Fr Sa So}
  p dayrange.to_s #=> "Mo, Mi-So"
end
