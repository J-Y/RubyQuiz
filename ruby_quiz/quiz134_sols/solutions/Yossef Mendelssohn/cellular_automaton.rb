#!/usr/bin/env ruby

require 'optparse'

cells = nil
steps = nil
rule  = nil
OptionParser.new do |opts|
  opts.on('-c', '--cells [CELLS]', 'A string representing the initial cell state as a series of 1s and 0s') do |cells_opt|
    cells = cells_opt
  end
  opts.on('-s', '--steps [STEPS]', Integer, 'The number of steps to simulate') do |steps_opt|
    steps = steps_opt.to_i
  end
  opts.on('-r', '--rule [RULE]', Integer, 'The rule as a decimal integer') do |rule_opt|
    rule = ('%b' % rule_opt)[0,8].rjust(8, '0')
  end
  opts.parse!(ARGV)
end

rule_table = {}
(0..7).to_a.reverse.collect { |n|  '%b' % n }.zip(rule.split('')) do |n, r|
  rule_table[n.rjust(3, '0')] = r
end

cells = ('0' * steps) + cells + ('0' * steps)

puts cells.gsub(/1/, 'X').gsub(/0/, ' ')
steps.times do
  check_cells = "0#{cells}0"  # pad with zeroes for ease of checking
  new_cells   = ''

  (0...cells.length).each do |i|
    neighborhood = check_cells[i, 3]
    new_cells << rule_table[neighborhood]
  end
  cells = new_cells
  puts cells.gsub(/1/, 'X').gsub(/0/, ' ')
end
