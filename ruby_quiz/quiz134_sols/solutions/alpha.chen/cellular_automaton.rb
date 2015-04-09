#!/usr/bin/env ruby

require 'enumerator'
require 'optparse'

rule = 110
steps = 20
cells = 1

OptionParser.new do |opts|
  opts.on("-r RULE", Integer) {|rule|}
  opts.on("-s STEPS", Integer) {|steps|}
  opts.on("-c CELLS", Integer) {|cells|}
end.parse!

cells = cells.to_s(2)

steps.times do
  puts cells.gsub('0', ' ').gsub('1', 'X')

  cells = "00#{cells}00".split(//).enum_for(:each_cons, 3)
  cells = cells.map {|neighborhood| rule[neighborhood.join.to_i(2)] }.join
end
