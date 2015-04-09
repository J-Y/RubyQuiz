require 'optparse'

rule, steps, cells = 145, 20, '1'

OptionParser.new do |opts|
  opts.on("-r RULE", Integer) {|rule|}
  opts.on("-s STEPS", Integer) {|steps|}
  opts.on("-c CELLS", String) {|cells|}
end.parse!

size = steps + cells.size + steps
line = cells.center(size, '0')

steps.times do
  puts line.tr('01', ' X')
  widened = line[0, 1] + line + line[-1, 1]
  line = (0...size).map{|i| rule[widened[i, 3].to_i(2)]}.join
end
