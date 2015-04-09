# This is a solution to Ruby Quiz #146 (see http://www.rubyquiz.com/)
# by LearnRuby.com and released under the Creative Commons
# Attribution-Share Alike 3.0 United States License.  This source code can
# also be found at:
#   http://learnruby.com/examples/ruby-quiz-146.shtml

# This file processes the input and creates an array of records
# containing the processed data.

require 'common'

# the structures we'll generate at various stages of the processing
Record1 = Struct.new(:time, :detector)
Record2 = Struct.new(:time, :direction)
Record3 = Struct.new(:time, :direction, :speed)
Record4 =
  Struct.new(:absolute_time, :day, :hour, :minute, :second, :direction, :speed)

# assign the two detectors to values
Detector_A = 0
Detector_B = 1


def analyze(filename)
  # arrays that will hold data at various stages of processing
  records1 = []
  records2 = []
  records3 = []

  # step 1. load in raw data, but convert times to raw times that
  # incorporate the day
  open(filename) do |f|
    day = 0
    last_time = nil
    f.each_line do |line|
      detector = line[0, 1] == 'A' ? Detector_A : Detector_B
      time = line[1..-1].to_i
      
      day += 1 if last_time && time < last_time
      last_time = time
      
      time += day * MillisecondsPerDay
      
      records1 << Record1.new(time, detector)
    end
  end
  
  # step 2. go from detector-based data to direction-based data
  records1.each_with_index do |record, i|
    if record.detector == Detector_A
      # number of B Detector hits that are close enough in time
      matches = 0
      
      (i + 1).upto(records1.size - 1) do |j|
        other_record = records1[j]
        break if other_record.time - record.time > SameTiresLimit
        next unless other_record.detector == Detector_B
        matches += 1
      end
      raise "too many matches" unless matches <= 1
      
      # matches will now be 0 or 1, indicating direction of travel
      records2 << Record2.new(record.time, matches)
    end
  end
  
  # step 3. go from direction-based data to car-direction-based data
  direction = [nil, nil]
  records2.each_with_index do |record, i|
    if direction[record.direction]
      speed = SpeedFactor / (record.time - direction[record.direction])
      records3 << Record3.new(direction[record.direction],
                              record.direction,
                              speed)
      direction[record.direction] = nil
    else
      direction[record.direction] = record.time
    end
  end
  
  # step 4. go from raw times to day, hour, minute, second data
  records3.map! do |record|
    day, ms_within_day = record.time.divmod MillisecondsPerDay
    hour, ms_within_hour = ms_within_day.divmod MillisecondsPerHour
    minute, ms_within_minute =
      ms_within_hour.divmod MillisecondsPerMinute
    second = ms_within_minute / MillisecondsPerSecond.to_f

    Record4.new(record.time, day, hour, minute, second,
                record.direction, record.speed)
  end
  
  records3
end


if $0 == __FILE__
  results = analyze("vehicle_counter.data")
  puts "read and processed data for %d vehicles" % results.size
end
