#!/usr/bin/ruby -w

require 'rubygems'
require 'nano/enumerable/each_combination'

# Pinewood Derby Chart generator.
# run without arguments for usage instructions.

class Array

  # returns mean of array contents
  def mean
    temp = flatten.compact
    return nil if temp.empty?
    temp.inject { |sum, v| sum + v } / temp.size.to_f
  end

  # returns variance of array contents
  def variance
    temp = flatten.compact
    return nil if temp.empty?
    return 0 if temp.size == 1
    m = temp.mean
    temp.collect {|v| (v - m)**2 }.mean
  end

  # returns std deviation of array contents
  def stddev
    Math.sqrt(variance)
  end

end

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

  # returns a fairly decent representation of the table
  # as long as each element is an integer
  def inspect
    return if @arr.empty?
    w = @arr.compact.collect { |row| row.size }.max
    result = "\n    " 
    w.times do |y|
      result += '%3d'%y
    end
    result += "\n"
    @arr.each_index do |x|
      result += '%3d:'%x
      if @arr[x]
        @arr[x].each do |val|
          result += val.nil? ? '   ' : '%3d'%val
        end
      end
      result += "\n"
    end
    result
  end

  # return the table's underlying array
  def to_a
    @arr
  end

end

# internal exception raised when the generator algorithm
# exhausts the available cars to select prematurely
class NoCarsException < RuntimeError
end

# Pinewood Derby chart
class Chart

  attr_reader :lanes, :cars, :rounds, :chart, :devs

  # coefficients for weighting formula for lane assignment.
  # these were derived by experimentation.
  FL = 3.0
  FP = 1.0
  FD = 3.0

  # create a new empty chart with given lanes, cars, and rounds.
  def initialize(lanes, cars, rounds)
    raise "Need at least #{lanes} cars" unless cars >= lanes
    raise "Need at least 1 round" unless rounds >= 1
    @lanes = lanes
    @cars = cars
    @rounds = rounds
    @chart = []
  end

  # create a chart by parsing from a string created by dump
  def self.parse(s)
    a = s.to_a
    lanes = a.shift.to_i
    cars = a.shift.to_i
    rounds = a.shift.to_i
    ch = Chart.new(lanes, cars, rounds)
    a.each do |line|
      ch.chart.push line.split.collect {|x| x.to_i}
    end
    ch.compute_stats
    ch
  end

  # returns dump of chart data
  def dump
    result = ''
    result << "#{lanes}\n"
    result << "#{cars}\n"
    result << "#{rounds}\n"
    chart.each do |heat|
      result << heat.join(' ') << "\n"
    end
    result
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

  # compute statistics for current chart
  def compute_stats

    # assigned heats by car
    @ah = Array.new(cars) { 0 }

    # assignments by car/lane
    @al = Array.new(cars) { Array.new(lanes) { 0 } }

    # matchups by car pair
    @op = Matchups.new
    (0...@cars).to_a.each_combination(2) { |x,y| @op[x,y] = 0 if x != y }

    # intervals by car
    lh = Array.new(cars)
    @iv = Array.new(cars) { Array.new }

    # accumulate statistics
    @chart.each_with_index do |h, heat|
      h.each_with_index do |car, lane|
        @ah[car] += 1
        @al[car][lane] += 1
        @iv[car] << heat - lh[car] + 1 if lh[car]
        lh[car] = heat
      end
      h.each_combination(2) {|x,y| @op[x,y] += 1}
    end

    # compute std dev's of each key metric
    @devs = [
      @ah.stddev,             # heats per car
      @al.stddev,             # lanes per car
      @op.to_a.stddev,        # matchups
      @iv.stddev,             # intervals
    ]

  end

  # prints the statistics for the current chart
  def print_stats(io = $stdout)

    raise "No chart has been generated" if @chart.empty?

    io.puts "\nStats:"

    io.puts "\nTotal Heats by Car (Target=#{@lanes * @rounds}):"
    temp = []
    cars.times do |car|
      io.printf "%4d:%4d\n", car, @ah[car]
    end
    io.puts "min=#{@ah.flatten.min}, max=#{@ah.flatten.max}, mean=#{@ah.mean}, stddev=#{@ah.stddev}"

    io.puts "\nLane Assignments by Car (Target=#{@rounds}):"
    io.print '     '
    lanes.times { |lane| io.printf '%4d', lane }
    io.puts
    cars.times do |car|
      io.printf '%4d:', car
      @al[car].each { |count| io.printf '%4d', count }
      io.puts
    end
    io.puts "min=#{@al.flatten.min}, max=#{@al.flatten.max}, mean=#{@al.mean}, stddev=#{@al.stddev}"

    io.print "\nMatchups (Target=#{Float(@lanes) * Float(@lanes - 1) * @rounds / Float(@cars - 1)}):"
    io.print @op.inspect
    io.puts "min=#{@op.to_a.flatten.compact.min}, max=#{@op.to_a.flatten.compact.max}, mean=#{@op.to_a.mean}, stddev=#{@op.to_a.stddev}"

    io.puts "\nIntervals by Car (Target=#{Float(@cars) / @lanes}):"
    temp = []
    @cars.times do |car|
      io.printf '%4d:', car
      @iv[car].each { |interval| io.printf '%4d', interval }
      io.puts
    end
    io.puts "min=#{@iv.flatten.min}, max=#{@iv.flatten.max}, mean=#{@iv.mean}, stddev=#{@iv.stddev}"

  end

end

class ChaoticChart < Chart

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

class RoundRobinChart < Chart

  # generate chart via simple round-robin assignment
  def generate
    chart.clear
    car = 0
    (cars * rounds).times do |heat|
      h = []
      lanes.times do
        h << car
        car = (car + 1) % cars
      end
      chart << h
    end
  end

end

if $0 == __FILE__

  if (ARGV.size < 3)
    puts "Usage: #$0 lanes cars rounds [class]"
    puts "       (constraints: lanes > 1, cars >= lanes, rounds >= 1)"
    exit
  end
  klass = 'ChaoticChart'
  klass = ARGV.pop if ARGV.size == 4
  c = Object.const_get(klass).new(*ARGV.collect {|v| v.to_i}) rescue begin
    $stderr.puts $!
    exit
  end
  c.generate
  c.print_chart
  c.compute_stats
  c.print_stats

end
