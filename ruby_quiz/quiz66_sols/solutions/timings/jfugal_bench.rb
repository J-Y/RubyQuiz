require "benchmark"
require "generator"
require "jfugal_faster_generator"
require "rbamf_fgenerator.rb"

tests = 100
enum  = (1..1000).to_a

puts
puts "### Construction ###"
puts

Benchmark.bmbm do |x|
  x.report("#{RUBY_VERSION} - #{RUBY_RELEASE_DATE}") do
    tests.times { Generator.new(enum) }
  end
  x.report("My ThreadedGenerator") do
    tests.times { TGenerator.new(enum) }
  end
  x.report("lukfugl's FasterGenerator") do
    tests.times { FasterGenerator.new(enum) }
  end
end

puts
puts "### next() ###"
puts

Benchmark.bmbm do |x|
  x.report("#{RUBY_VERSION} - #{RUBY_RELEASE_DATE}") do
    generator = Generator.new(enum)
    tests.times {
      generator.rewind
      generator.next until generator.end?
    }
  end
  x.report("My ThreadedGenerator") do
    generator = TGenerator.new(enum)
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
