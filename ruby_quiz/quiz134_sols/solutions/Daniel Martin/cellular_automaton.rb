#!ruby
require 'optparse'

rule = 30
initial_pattern = '1'
steps = 10
OptionParser.new do |opts|
  opts.banner = "Usage: ca.rb [opts]"
  opts.on("-r", "--rule N", Integer, "Rule number") do |n|
    rule = n
  end
  opts.on("-s", "--states N", Integer,
                "Number of states (default 10)") do |s|
    steps = s
  end
  opts.on("-c", "--cells BITSTRING", String,
                "Initial cell pattern as 0s and 1s") do |s|
    initial_pattern = s
  end
end.parse!

# This ensures some padding for those nasty odd rules
pattern = '0' * steps + initial_pattern + '0' * steps;
(steps-1).times {
  puts pattern.tr('01',' X')
  ppat = pattern[0,1] + pattern + pattern[-1,1]
  pattern = (1..pattern.size).inject(""){|s,i|
    s << ((rule >> [ppat[i-1,3]].pack('b3')[0])&1).to_s
  }
}
puts pattern.tr('01',' X')
