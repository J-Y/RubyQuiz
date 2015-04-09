=begin
Justin Ethier
November 2007

Solution to Ruby Quiz 146 - Vehicle Counters 
(See: http://www.rubyquiz.com/quiz146.html)
=end

# Constants
MSecPerMin = 1000 * 60
MSecPerHour = MSecPerMin * 60
InchesPerMile = 63360

# Class to analyze and report on data for a single direction
class DirectionDataReport
  Verbose = false
  Sensors = %w(Northbound Southbound)
  Days = %w(Mon Tue Wed Thu Fri Sat Sun)
  
  # Inputs: Raw data is a list of times [start_ms, end_ms] for one direction
  def initialize(raw_data)
    @raw_data = raw_data
  end
  
  # Print a report to console
  def report(sensor, report_averages)
    puts "Direction: #{Sensors[sensor]}"
    puts "Total Cars: #{self.total_count}"
    
    report_time_periods(sensor, report_averages, MSecPerHour * 12)
    report_time_periods(sensor, report_averages, MSecPerHour)
    report_time_periods(sensor, report_averages, MSecPerHour / 2)
    report_time_periods(sensor, report_averages, MSecPerHour / 4)
    puts ""
  end
  
  # Segment data according to given time period
  def create_time_periods(time_period_length = MSecPerHour)
    days = []
    time_periods = nil
    prev_start = @raw_data[0][0] + 1 # cross over into first day
    
    for data in @raw_data
      # Has data crossed over to next day?
      if prev_start > data[0] # Time increases throughout the day...
        days << time_periods if time_periods != nil
        
        cur_time_period = 0
        time_periods = [[]]
        
        puts "New day: data=#{data[0]}" if Verbose
        
      # Has data crossed over to next time period?
      elsif data[0] > ((cur_time_period + 1) * time_period_length)
        # Handle cases where the count is 0 for a time period
        while data[0] > ((cur_time_period + 1) * time_period_length)
          cur_time_period += 1
          time_periods[cur_time_period] = []
        end
        
        puts "New time period: data=#{data[0]}" if Verbose
      end
      
      time_periods[cur_time_period] << data
      prev_start = data[0]
    end
    
    # Add last time period
    days << time_periods
    days
  end
  
  # Create a report for a specific time period
  def report_time_periods(sensor, report_averages, time_period_length)
    days = create_time_periods(time_period_length)
    num_time_periods = (MSecPerHour * 24) / time_period_length # 24 hrs / X ms

    counts = count_per_time_period(days)
    avg_speeds = speed_per_time_period(days)
    avg_dists = dist_per_time_period(days)
    
    puts("\nTime Interval: #{time_period_length/MSecPerMin} Minutes")
    if (num_time_periods > 2)
      peaks = find_peak_times(days)
      puts("Peak Times")
      for i in 0...peaks.size
        printf("#{Days[i]}:")
        peaks[i].size.times {|p| printf(format_time_interval_index(peaks[i][p][1], time_period_length))}
        puts ""
      end
    end
    
    puts("Statistics")
    printf("Data    ")
    printf("\tDay") if not report_averages
    
    num_time_periods.times{|i| printf(format_time_interval_index(i, time_period_length))} 
    report_column_data(days, num_time_periods, report_averages, counts,     report_averages ? "Avg Count" : "Count    ", "% 5d")
    report_column_data(days, num_time_periods, report_averages, avg_speeds, "Avg Speed", "%02.02f")
    report_column_data(days, num_time_periods, report_averages, avg_dists,  "Avg Dist ", "%02.02f")
    puts ""
  end
  
  # Print tabular data
  def report_column_data(days, num_time_periods, report_averages, data, data_label, format_string)
    if report_averages
      printf("\n#{data_label}")
      for time in 0...num_time_periods
        avg = 0
        days.size.times {|day| avg += data[day][time] }
        printf("\t#{format_string}", avg / days.size)          
      end
    else
      for day in 0...days.size
        printf("\n#{data_label}\t#{Days[day]}")
        for time in 0...num_time_periods
          printf("\t#{format_string}", data[day][time])
        end
      end
    end
  end

  # Format time
  def format_time_interval_index(index, time_period_length)
    sprintf("\t%02d:%02d", 
        index * time_period_length / MSecPerHour,
        (index * time_period_length / MSecPerMin) % 60)
  end

  # Total vehicles recorded by this sensor
  def total_count()
    @raw_data.size
  end

  # Find n peak times per day
  def find_peak_times(days, num_peaks=4)
    days.map do |day| 
      find_daily_peak_times(day, num_peaks)
    end
  end
  
  # Find peak times for the given time periods
  def find_daily_peak_times(daily_time_periods, num_peaks)
    peaks = []
    daily_time_periods.size.times {|i| peaks << [daily_time_periods[i].size, i]}
    peaks.sort.reverse.slice(0, num_peaks).sort {|a,b| a[1]<=>b[1]}
  end
  
  # Count of vehicles for each time period
  def count_per_time_period(days)
    days.map do |day|
      day.map {|time_period| time_period.size}
    end
  end
  
  # Find average vehicle speed for daily time periods
  def speed_per_time_period(days)
    days.map do |day| 
      day.map {|time_period| calc_average_speed(time_period) } 
    end
  end

  # Find average distance between vehicles for daily time periods
  def dist_per_time_period(days)
    days.map do |day| 
      day.map {|time_period| calc_average_distance(time_period) } 
    end
  end  
  
  def calc_average_speed(time_period)
    return 0 if time_period.size == 0
    
    sum = 0    
    for time in time_period
      sum += calc_speed(time[0], time[1])
    end    
    sum / (time_period.size)
  end

  # Calculate speed based upon start/end times recorded by sensor
  # Assumes 100 inch wheelbase contraint from quiz statement
  def calc_speed(start_time, end_time)
    # Inches   MSec   Miles    Miles
    # ------ * ---- * ------ = -----
    #  MSec     Hr    Inches   Hour
    return (100.0 / (end_time - start_time)) * MSecPerHour / (InchesPerMile * 1.0) 
  end  
  
  # Calculate distance between cars for given time period
  def calc_average_distance(time_period)
    return 0 if time_period.size <= 1 # Need at least 2 cars
    sum = 0
    for i in 0...(time_period.size - 1)
      sum += calc_distance(time_period[0], time_period[1])
    end
    return sum / (time_period.size - 1)
  end

  # Estimates distance the follower car travels by assuming its speed is constant
  # Does not take into account the different speed of the leader car
  def calc_distance(leader_time, follower_time)
    # miles/hr * time_delta (in msecs) * msec/hr = miles between cars
    follower_speed = calc_speed(follower_time[0], follower_time[1])
    
    dist = follower_speed * ((follower_time[0] - leader_time[0]) / (MSecPerHour * 1.0))
    
    return dist
  end
end

# Class to parse raw data from file
class VehicleCounter
  Dir_A = 0
  Dir_B = 1
  
  # Parse data from input file
  #
  #  Assumes A / A is a record for one direction, and 
  #          A / B / A / B is for the other
  #
  # Would need to be beefed-up to handle cases where 2 cars pass at 
  # the same time in opposite directions. For now we ignore this case
  # because it does not really come up in the sample data.
  def parse(file)
    times = []
    dirs = [[], []]
    
    f = File.open(file)
    f.each_line do |line|
      sensor, time = parse_record(line)
      times << time
      
      if (times.size % 2) == 0
        if (times.size == 2 and sensor == Dir_A) or
           (times.size == 4 and sensor == Dir_B)
           
           # Remove "B" records from second direction
           times = [times[0], times[2]] if sensor == Dir_B
           
           dirs[sensor] << times
           times = []
         elsif (times.size == 4 and sensor != Dir_B)
          puts "Parse error"
          times = []
         end
      elsif (times.size % 2) == 1 and sensor == Dir_B
        puts "Parse error - Unexpected B record"
      end
    end
    f.close
    
    dirs
  end
  
  # Read and report on given file
  def process(file, report_averages)
    raw_data = parse(file)
    for sensor in 0..1 
      sensor_report = DirectionDataReport.new(raw_data[sensor])
      sensor_report.report(sensor, report_averages)
    end
  end
  
  # Parse raw record from vehicle counter file
  # Returns: Sensor, Timestamp
  def parse_record(data)
    unpacked = data.unpack("a1a*")
    return unpacked[0] == "A" ? Dir_A : Dir_B, unpacked[1].to_i
  end
end


if ARGV.size < 1
  puts "Usage: vehicle_counter.rb datafile [-avg]"
else
  vc = VehicleCounter.new
  vc.process(ARGV[0], ARGV[1] != nil)
end
