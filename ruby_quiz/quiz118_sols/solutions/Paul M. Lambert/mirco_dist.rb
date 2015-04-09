#!/opt/local/bin/ruby -w

# ruby quiz #118

$calculated_distance_for_number=Hash.new

class Integer
  def reversed_digits
    self.to_s.split('').reverse
  end
end

def position(digit)
  if digit.nil? or digit.to_i == 10
    return 1,3
  elsif digit.to_i == 0
    return 0,3
  else
    return ((digit.to_i - 1) % 3), ((digit.to_i - 1) / 3)
  end
end

def distance_between_digits(a,b)
  x1, y1 = position(a)
  x2, y2 = position(b)
  x = (x1 - x2).abs
  y = (y1 - y2).abs
  return (x*x + y*y)
end

def distance_for_number(num)
  num = num.to_i
  if $calculated_distance_for_number[num]
    return $calculated_distance_for_number[num]
  end
  d = num.to_i.reversed_digits
  total_distance = 0

  last_digit=nil
  while d.size > 0
    next_digit = d.shift
    total_distance += distance_between_digits(last_digit, next_digit)
    last_digit = next_digit
  end
  $calculated_distance_for_number[num] = total_distance
end

def all_representations_of(s)
  representations = Array.new
  mins = (s.to_i / 60)
  secs = s.to_i - 60*mins
  if mins == 0
    [ secs ]
  elsif secs > 39
    [ 100*mins+secs ]
  else
    [ 100*mins+secs, 100*(mins-1)+secs+60 ]
  end
end

def best_input_for(seconds, tolerance=0)
  tolerance=tolerance.to_i
  seconds=seconds.to_i
  range_min=[seconds-tolerance, 0].max
  range_max=seconds+tolerance
  representations = Array.new
  (range_min .. range_max).each do |s|
    representations.concat(all_representations_of(s))
  end
  representations.sort { |a,b| distance_for_number(a) <=> distance_for_number(b) }[0]
end

[99, 71, 120, 123].each do |s|
  puts "#{s}: #{best_input_for(s)}"
end
