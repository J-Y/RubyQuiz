#!/usr/bin/env ruby

require 'optparse'
require 'enumerator'

ruleset = 0
steps = 1
cells = ['0']
output_map = ' X'

OptionParser.new do |opts|
  opts.on("-r", "--ruleset RULESET", Integer, "Ruleset specification") {|r| ruleset = r }
  opts.on("-s", "--steps STEPS", Integer, "Number of steps") {|s| steps = s}
  opts.on("-c", "--cells CELLS", "Initial cells string") {|c| cells = c.split(//)}
  opts.on("-m", "--map MAP", "Character map for output") {|m| output_map = m}
end.parse!(ARGV)

rule = {}
0.upto(7) {|i| rule[sprintf("%03b", i).split(//)] = ruleset[i].to_s}

width = steps * 2 + cells.length + 1
0.upto(steps) do
  puts cells.join.tr('01', output_map).center(width)
  cells = (['0','0'] + cells + ['0','0']).enum_cons(3).map {|l| rule[l]}
end
