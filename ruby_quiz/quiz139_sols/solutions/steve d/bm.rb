require 'benchmark'
require 'pp'

random_ips = Array.new(1000).map { Array.new(4).map {rand(256)}.join('.') }

sols = Dir["*.rb"] - [$0]

times = {}

sols.each do |fn|
  stats = Benchmark.measure do
    random_ips.each do |ip|
      %x{ ruby #{fn} #{ip} }
    end
  end
  times[fn] = stats
end

sort_times = proc { |m| times.sort_by{|(k,v)| v.send(m)}.map{|(k,v)| [k, v.send(m)]} }

puts "sorted by real time"
pp sort_times[:real]
puts

puts "sorted by sys time"
pp sort_times[:stime]
puts

puts "sorted by user time"
pp sort_times[:utime]
