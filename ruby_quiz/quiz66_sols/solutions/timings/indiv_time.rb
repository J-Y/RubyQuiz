#!/usr/local/bin/ruby -w

require "benchmark"

sc, ec = [], []
ObjectSpace.each_object(Class) { |c| sc << c if c.name =~ /Generator/ }
ARGV.each { |f| require f }
ObjectSpace.each_object(Class) { |c| ec << c if c.name =~ /Generator/ }
generators = ec - sc

tests = 10
enum  = (1..1000).to_a

puts
puts "Test: #{generators.join}"
puts "### Construction ###"
puts

Benchmark.bmbm do |x|
  generators.each do |genclass|
    x.report(genclass.name) do
      (tests * 100).times { genclass.new(enum) }
    end
  end
end

puts
puts "### next() ###"
puts

Benchmark.bmbm do |x|
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
