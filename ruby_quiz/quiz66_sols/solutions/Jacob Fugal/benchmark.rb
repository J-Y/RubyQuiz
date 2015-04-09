require "benchmark"
require "callcc_generator"
require "faster_generator"

tests = 100
enum  = (1..1000).to_a

puts
puts "### Construction ###"
puts

Benchmark.bmbm do |x|
  x.report("Old callcc Generator") do
    tests.times { CallCCGenerator.new(enum) }
  end
  x.report("lukfugl's FasterGenerator") do
    tests.times { FasterGenerator.new(enum) }
  end
end

puts
puts "### next() ###"
puts

Benchmark.bmbm do |x|
  x.report("Old callcc Generator") do
    generator = CallCCGenerator.new(enum)
    tests.times {
      generator.rewind
      generator.next until generator.end?
    }
  end
  x.report("lukfugl's FasterGenerator") do
    generator = FasterGenerator.new(enum)
    tests.times {
      generator.rewind
      generator.next until generator.end?
    }
  end
end
