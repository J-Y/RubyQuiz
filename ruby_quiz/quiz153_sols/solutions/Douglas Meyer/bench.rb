#!/usr/bin/env ruby

require 'benchmark'

#VERBOSE = ENV['VERBOSE'] || false
FILES = [ 'longest_first.rb', 'shortest_first.rb' ]
COLLECTION = %w(0 1 2 3 4 5 6 7 8 9
  a b c d e f g h i j k l m n o p q r s t u v w x y z)[0..-1]

if __FILE__ == $0
  count = ARGV[0]
  if count.nil?
    STDOUT << "Useage: #{__FILE__} count\n"
  else

    tests = []
    count.to_i.times do
      string = ''
      60.times { string << COLLECTION.sort_by{rand}.first }
      tests << string
    end

    FILES.each do |file|
      puts file
      time = Benchmark.measure do
        tests.each do |test|

          result = %x(./#{file} #{test})
          puts "#{test} -> #{result}"

        end
      end
      puts "#{file}: #{time.real}"
    end

  end
end
