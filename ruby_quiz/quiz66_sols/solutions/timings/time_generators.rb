#!/usr/local/bin/ruby -w

require "benchmark"

sc, ec = [], []
ObjectSpace.each_object(Class) { |c| sc << c if c.name =~ /Generator/ }
(Dir['*generator.rb'] + ['horndude_generator.so']).each { |f| require f }
ObjectSpace.each_object(Class) { |c| ec << c if c.name =~ /Generator/ }
generators = (ec - sc - [ThreadGenerator, CallCCGenerator]).sort_by { |x| x.name }.reverse

tests = 10
enum  = (1..1000).to_a

if ARGV[0] == '1'
  puts
  puts "### Construction ###"
  puts

  Benchmark.bmbm do |x|
    x.report("New Thread Generator") do
      (tests * 100).times { ThreadGenerator.new(enum) }
    end

    x.report("Old callcc Generator") do
      (tests * 100).times { CallCCGenerator.new(enum) }
    end

    generators.each do |genclass|
      x.report(genclass.name) do
        (tests * 100).times { genclass.new(enum) }
      end
    end
  end
else
  puts
  puts "### next() ###"
  puts

  Benchmark.bmbm do |x|
    x.report("New Thread Generator") do
      generator = ThreadGenerator.new(enum)
      tests.times do 
        generator.rewind
        generator.next until generator.end?
      end
    end


    x.report("Old callcc Generator") do
      generator = CallCCGenerator.new(enum)
      tests.times do 
        generator.rewind
        generator.next until generator.end?
      end
    end

    generators.each do |genclass|
      x.report(genclass.name) do
        generator = genclass.new(enum)
        tests.times do 
          generator.rewind
          generator.next until generator.end?
        end
      end
    end
  end
end
