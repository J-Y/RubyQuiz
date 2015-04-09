#!/usr/bin/env ruby
# Ruby Quiz 156: Internal Rate of Return
# Jesse Merriman, Maxima version
# (http://www.jessemerriman.com/project/ltf)

require 'ltf'
include LTF

class Array
  def map_with_index
    mapped = []
    each_with_index { |x, i| mapped << yield(x, i) }
    mapped
  end
end

if __FILE__ == $0
  cash_flows = ARGV[0..-2]
  accuracy = ARGV[-1].to_i
  
  eq = '0 = ' +
       cash_flows.map_with_index { |x, i| "#{x}/(1+irr)^#{i}" }.join(' + ')

  max = Maxima.new "fpprec: #{accuracy};"
  max.puts "res: solve([#{eq}], [irr]);"

  sols = []
  num_sols = max.puts('length(res);').to_i
  num_sols.times { |i| sols << max.puts("bfloat(res[#{i+1}]);") }

  real_sols, complex_sols = [], []
  sols.each do |s|
    if /%i/.match(s)
      complex_sols << s
    else
      real_sols << s
    end
  end

  puts 'Real solutions:'
  puts '  ' + real_sols.join("\n  ")
  puts 'Complex solutions:'
  puts '  ' + complex_sols.join("\n  ")

  max.quit
end
