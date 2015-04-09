#!/usr/local/bin/ruby -w

require "benchmark"

require "thread_generator"
require "callcc_generator"
require "faster_generator"

tests = 10
enum  = (1..1000).to_a

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
  x.report("Array-based FasterGenerator") do
    (tests * 100).times { FasterGenerator.new(enum) }
  end
end

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
  x.report("Array-based FasterGenerator") do
    generator = FasterGenerator.new(enum)
    tests.times do 
      generator.rewind
      generator.next until generator.end?
    end
  end
end
