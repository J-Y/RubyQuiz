# microwave.rb
# Ruby Quiz 118: Microwave Numbers

require 'metrics'
require 'pad'
require 'alternators'

# alternator is a Proc that takes the number of seconds and produces an
# Enumerable of equivalent values.
#
# metrics can be:
#   - a MetricStack
#   - a single metric Proc
#   - an Array of metric Procs
def microwave(seconds, pad = Pad.normal_pad,
              alternator = Exact, metrics = EuclideanMetric)
  case metrics
    when Proc;  metrics = MetricStack.new([metrics])
    when Array; metrics = MetricStack.new(metrics)
  end
  best = nil
  alternator[seconds].each do |sec|
    pad.each_button_sequence(sec) do |bs|
      best = bs if metrics.better?(bs, best)
    end
  end
  best
end

# Print out the best button sequences for all seconds in the given Enumerable.
# Other arguments are passed into microwave(). The thing that sucks about
# this is that if there's a tolerance of > 0, identical sequences will be
# scored more than once. Maybe memo-ize that or something..
def list(enum, pad = Pad.normal_pad,
         alternator = Exact, metrics = EuclideanMetric)
  puts "Seconds   Buttons"
  puts "-------   -------"
  enum.each do |i|
    best = microwave(i, pad, alternator, metrics)
    puts "#{i}         #{best}"
  end
end
