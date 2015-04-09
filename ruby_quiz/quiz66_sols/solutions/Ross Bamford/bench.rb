#!/usr/local/bin/ruby -w

require "benchmark"
require "fgenerator"
require "generator"
#require "profile"

tests = 100
enum  = (1..1000).to_a

puts
puts "### Construction ###"
puts

Benchmark.bmbm do |x|
   x.report("#{RUBY_VERSION}-#{RUBY_RELEASE_DATE} Generator") do
     tests.times { Generator.new(enum) }
   end
   x.report("My generator") do
     tests.times { FGenerator.new(enum) }
   end
end

puts
puts "### next() ###"
puts

Benchmark.bmbm do |x|
   x.report("#{RUBY_VERSION}-#{RUBY_RELEASE_DATE} Generator") do
     generator = Generator.new(enum)
     tests.times { generator.rewind; generator.next until generator.end? }
   end
   x.report("My generator") do     
     generator = FGenerator.new { |g| enum.each { |i| g.yield i } }
     tests.times { generator.rewind; generator.next until generator.end? }
   end
end

