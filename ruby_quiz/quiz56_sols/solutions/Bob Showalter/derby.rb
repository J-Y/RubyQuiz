#!/usr/bin/ruby -w

# Pinewood Derby Chart generator.
# run without arguments for usage instructions.

# two-dimensional table in which the order of the indices
# doesn't matter. e.g. foo[2,7] is the same cell as foo[7,2].
class Matchups

  def initialize
    @arr = []
  end

  def [](a, b)
    x, y = a, b
    x, y = y, x if x > y
    @arr[x] && @arr[x][y] || 0
  end

  def []=(a, b, val)
    x, y = a, b
    x, y = y, x if x > y
    @arr[x] ||= []
    @arr[x][y] = val
  end

end

# Pinewood Derby chart
class Chart

  attr_reader :lanes, :cars, :rounds, :chart, :devs

  # create a new empty chart with given lanes, cars, and rounds.
  def initialize(lanes, cars, rounds)
    raise "Need at least #{lanes} cars" unless cars >= lanes
    raise "Need at least 1 round" unless rounds >= 1
    @lanes = lanes
    @cars = cars
    @rounds = rounds
    @chart = []
  end

  # prints the chart
  def print_chart(io = $stdout)
    io.puts "Chart:"
    h = 0
    chart.each do |heat|
      io.printf "%4d: ", h
      heat.each do |car|
        io.printf "%4d", car
      end
      io.puts
      h += 1
    end
  end

end

# internal exception raised when the generator algorithm
# exhausts the available cars to select prematurely
class NoCarsException < RuntimeError
end

class ChaoticChart < Chart

  # coefficients for weighting formula for lane assignment.
  # these were derived by experimentation.
  FL = 3.0
  FP = 1.0
  FD = 3.0

  # generates the chart by assigning cars to heats
  def generate

    begin
      # assigned heats by car, last heat by car
      ah = Array.new(cars) { 0 }
      lh = Array.new(cars)

      # assignments by car/lane
      al = Array.new(cars) { Array.new(lanes) { 0 } }

      # matchups by car pair
      op = Matchups.new

      # schedule by heat by lane
      chart.clear

      # generate each heat
      (cars * rounds).times do |heat|

        # current car assignments by lane
        h = []

        # slot each lane
        lanes.times do |lane|

          # computed weights for each car
          w = {}

          # assign weights to each car for this slot
          cars.times do |car|

            # skip car if it's already been slotted to this heat
            next if h.include? car

            # skip car if it's already run max heats in this lane
            next if al[car][lane] >= @rounds

            # weight factor 1: no. of times slotted to this lane
            f1 = FL * al[car][lane]

            # weight factor 2: no. of times against these opponents
            f2 = FP * h.inject(0) do |f, opp|
              f + op[car, opp]
            end

            # weight factor 3: no. of heats since last scheduled
            # (distribute cars through the heats)
            f3 = 0
            if lh[car]
              f3 = FD * (cars / lanes) / (heat - lh[car])
            end

            # total weight for this car
            w[car] = f1 + f2 + f3

          end

          raise NoCarsException if w.empty?

          # sort by weight and get the lowest weight(s)
          w = w.sort_by { |k, v| v }
          w.pop while w[-1][1] > w[0][1]

          # randomly choose a car and slot it
          car = w[rand(w.size)][0]

          # accumulate statistics
          ah[car] += 1
          lh[car] = heat
          al[car][lane] += 1
          h.each do |opp|
            op[car, opp] += 1
          end

          # slot car to current heat
          h << car

        end

        # add current heat to chart
        chart << h

      end

    rescue NoCarsException
      retry

    end

  end

end

if $0 == __FILE__
  if (ARGV.size != 3)
    puts "Usage: #$0 lanes cars rounds"
    puts "       (constraints: lanes > 1, cars >= lanes, rounds >= 1)"
    exit
  end
  c = ChaoticChart.new(*ARGV.collect {|v| v.to_i}) rescue begin
    $stderr.puts $!
    exit
  end
  c.generate
  c.print_chart
end
