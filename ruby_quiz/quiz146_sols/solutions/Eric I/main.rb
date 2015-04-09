# This is a solution to Ruby Quiz #146 (see http://www.rubyquiz.com/)
# by LearnRuby.com and released under the Creative Commons
# Attribution-Share Alike 3.0 United States License.  This source code can
# also be found at:
#   http://learnruby.com/examples/ruby-quiz-146.shtml

# This file is the main entry point to the program.

require 'traffic_analyzer'
require 'traffic_grapher'

records = analyze "vehicle_counter.data"

AllDaySequences.each do |day_filter|
  graph "%s Volume by Hour and Direction" % day_filter.name, records do
    filter day_filter
    series WestboundFilter
    series EastboundFilter
    bins HourSequence
    combiner VolumeCombiner
  end

  AllDirectionSequence.each do |direction_filter|
    graph("%s %s Volume by AM-PM" % [day_filter.name, direction_filter.name],
          records) do
      filter day_filter
      series OneSequence
      bins AM_PM_Sequence
      combiner VolumeCombiner
    end

    graph("%s %s Volume by Hour" % [day_filter.name, direction_filter.name],
          records) do
      filter day_filter
      series OneSequence
      bins HourSequence
      combiner VolumeCombiner
    end

    graph("%s %s Volume by Half Hour" %
            [day_filter.name, direction_filter.name],
          records) do
      filter day_filter
      series FirstHalfHourFilter
      series SecondHalfHourFilter
      bins HourSequence
      combiner VolumeCombiner
    end

    graph("%s %s Volume by Third Hour" %
            [day_filter.name, direction_filter.name],
          records) do
      filter day_filter
      series FirstThirdHourFilter
      series SecondThirdHourFilter
      series ThirdThirdHourFilter
      bins HourSequence
      combiner VolumeCombiner
    end

    graph("%s %s Volume by Quarter Hour" %
            [day_filter.name, direction_filter.name],
          records) do
      filter day_filter
      series FirstQtrHourFilter
      series SecondQtrHourFilter
      series ThirdQtrHourFilter
      series FourthQtrHourFilter
      bins HourSequence
      combiner VolumeCombiner
    end
  end
end

graph "Maximum Speed by Hour and Direction", records do
  series WestboundFilter
  series EastboundFilter
  bins HourSequence
  combiner MaxSpeedCombiner
end

graph "Minimum Speed by Hour and Direction", records do
  series WestboundFilter
  series EastboundFilter
  bins HourSequence
  combiner MinSpeedCombiner
end

graph "Average Speed by Hour and Direction", records do
  series WestboundFilter
  series EastboundFilter
  bins HourSequence
  combiner AverageSpeedCombiner
end

graph "Speed Distribution by Direction", records do
  series DirectionSequence
  bins SpeedRangeSequence
  combiner VolumeCombiner
end

graph "Speed Distribution by AM-PM", records do
  series AM_PM_Sequence
  bins SpeedRangeSequence
  combiner VolumeCombiner
end

graph "Intra-Car Distance in Feet by Hour and Direction", records do
  series WestboundFilter
  series EastboundFilter
  bins HourSequence
  combiner AverageDistanceCombiner
end

graph "Intra-Car Distance in Feet by Quarter Hour", records do
  series QuarterHourSequence
  bins HourSequence
  combiner AverageDistanceCombiner
end
