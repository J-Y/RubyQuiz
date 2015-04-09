# This is a solution to Ruby Quiz #146 (see http://www.rubyquiz.com/)
# by LearnRuby.com and released under the Creative Commons
# Attribution-Share Alike 3.0 United States License.  This source code can
# also be found at:
#   http://learnruby.com/examples/ruby-quiz-146.shtml

# This file creates a set of filters and combiners that allow grapher
# to be used with the vehicle data.

require 'grapher'

# Day of the week filters and sequences

AllDayFilter = ValueFilter.new("Combined Days", 0..5, :day)
MondayFilter = ValueFilter.new("Monday", 0, :day)
TuesdayFilter = ValueFilter.new("Tuesday", 1, :day)
WednesdayFilter = ValueFilter.new("Wednesday", 2, :day)
ThursdayFilter = ValueFilter.new("Thursday", 3, :day)
FridayFilter = ValueFilter.new("Friday", 4, :day)

DaySequence =
  [MondayFilter, TuesdayFilter, WednesdayFilter, ThursdayFilter, FridayFilter]

AllDaySequences = [AllDayFilter] + DaySequence

# Hour filters and sequences

AM_Filter = ValueFilter.new("AM", 0..11, :hour)
PM_Filter = ValueFilter.new("PM", 12..23, :hour)

AM_RushHourFilter = ValueFilter.new("AM Rush Hour", 7..9, :hour)
PM_RushHourFilter = ValueFilter.new("PM Rush Hour", 4..6, :hour)

Ten_AM_Filter = ValueFilter.new("10 AM", 10, :hour)

FirstHalfHourFilter = ValueFilter.new(":00 - :29", 0..29, :minute)
SecondHalfHourFilter = ValueFilter.new(":30 - :59", 30..59, :minute)

FirstThirdHourFilter = ValueFilter.new(":00 - :19", 0..19, :minute)
SecondThirdHourFilter = ValueFilter.new(":20 - :39", 20..39, :minute)
ThirdThirdHourFilter = ValueFilter.new(":40 - :59", 40..59, :minute)

FirstQtrHourFilter = ValueFilter.new(":00 - :14", 0..14, :minute)
SecondQtrHourFilter = ValueFilter.new(":15 - :29", 15..29, :minute)
ThirdQtrHourFilter = ValueFilter.new(":30 - :44", 30..44, :minute)
FourthQtrHourFilter = ValueFilter.new(":45 - :59", 45..59, :minute)

AM_PM_Sequence = [AM_Filter, PM_Filter]
RushHourSequence = [AM_RushHourFilter, PM_RushHourFilter]
QuarterHourSequence =
  [FirstQtrHourFilter, SecondQtrHourFilter, ThirdQtrHourFilter, FourthQtrHourFilter]

HourSequence = (0..23).map { |hour|
  label = case hour
          when 0 : '12m'
          when 1..11 : "%da" % hour
          when 12 : '12n'
          else "%dp" % (hour - 12)
          end
  ValueFilter.new(label, hour, :hour)
}

MorningHourSequence = HourSequence[0...12]
AfternoonHourSequence = HourSequence[12...24]

# Direction filters and sequences

WestboundFilter = ValueFilter.new("Westbound", 0, :direction)
EastboundFilter = ValueFilter.new("Eastbound", 1, :direction)
BothDirectionFilter = ValueFilter.new("Both Directions", 0..1, :direction)

DirectionSequence = [WestboundFilter, EastboundFilter]
AllDirectionSequence = [BothDirectionFilter] + DirectionSequence

# Speed Filters

SpeedRangeSequence = []
[20, 25, 30, 35, 40, 45, 50, 55, 60].each_cons(2) do |low, high|
  SpeedRangeSequence <<
    ValueFilter.new("%d-%d" % [low, high - 1], low...high, :speed)
end

# Combiners

VolumeCombiner = Proc.new { |data| data.size }

AverageSpeedCombiner = Proc.new do |records|
  if records.size == 0
    0
  else
    records.inject(0) { |t, d| t + d.speed } / records.size.to_f
  end
end

MaxSpeedCombiner = Proc.new do |records|
  if records.size == 0
    0
  else
    records.map { |r| r.speed }.max
  end
end

MinSpeedCombiner = Proc.new do |records|
  if records.size == 0
    0
  else
    records.map { |r| r.speed }.min
  end
end

AverageDistanceCombiner = Proc.new do |records|
  distances = []

  (0..1).each do |direction|
    selected_records = records.select { |r| r.direction == direction }
    selected_records.each_cons(2) do |r1, r2|
      time = r2.absolute_time - r1.absolute_time

      # if times are more than an hour apart, then they're on separate
      # days
      next if time > 1000 * 60 * 60

      r1_speed = r1.speed / InchesPerMillisecondToMilesPerHour
      r2_speed = r2.speed / InchesPerMillisecondToMilesPerHour

      distance1 = time * r1_speed - AverageCarLength
      distance2 = time * r2_speed - AverageCarLength
      distance = (distance1 + distance2) / 2
      distance_feet = distance / 12
      distances << distance_feet
    end
  end

  average_distance =
    if distances.size == 0
      0
    else
      sum = distances.inject { |t, dist| t + dist }
      sum / distances.size.to_f
    end

  average_distance
end
