#!/usr/bin/env ruby
# Ruby Quiz 141: Probable Iterations

require 'getoptlong'

module Enumerable
  def count obj
    c = 0
    each { |x| c += 1 if x == obj }
    c
  end
end

def each_roll num_dice, sides
  (0...sides**num_dice).each do |x|
    x = x.to_s sides
    x = '0' * (num_dice - x.length) + x
    yield x.split(//).map { |n| n.to_i + 1 }
  end
end

def make_test n, min
end

if __FILE__ == $0
  Opts = GetoptLong.new(
    [ '--verbose', '-v', GetoptLong::NO_ARGUMENT ],
    [ '--sample',  '-s', GetoptLong::NO_ARGUMENT ] )

  # defaults
  verbose = false
  sample  = false
  sample_rate = 50_000
  sides   = 6

  Opts.each do |opt, arg|
    case opt
      when '--verbose'; verbose = true
      when '--sample';  sample  = true
    end
  end

  num_dice = ARGV.shift.to_i
  min_5s   = ARGV.shift.to_i

  i, hits = 0, 0
  roll, passed = nil, nil

  test = lambda { |roll| roll.count(5) >= min_5s }

  printer = lambda do
    print "#{i} #{roll.inspect}"
    print ' <==' if passed
    puts
  end

  each_roll num_dice, sides do |roll|
    i += 1
    passed = test[roll]
    hits += 1 if passed
    printer[] if verbose or (sample and (i % sample_rate) == 1 )
  end

  puts "\nNumber of desirable outcomes is #{hits}"
  puts "Number of possible outcomes is #{i}"
  puts "\nProbability is #{hits.to_f / i}"
end
