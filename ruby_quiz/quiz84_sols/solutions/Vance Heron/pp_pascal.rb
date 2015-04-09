#! /usr/bin/env ruby

num_lines = ARGV[0].to_i - 1
tri = []
(0..num_lines).each do |n|
 line = [ 1 ]
 (1..n/2).each{|e| line[e] = tri[n-1][e-1] + tri[n-1][e] }
 tri[n] = line + line[0..(n%2)-2].reverse
end

width = Math.log10(tri[num_lines][num_lines/2]).ceil + 1

(0..num_lines).each do |n|
 print ' ' * ((num_lines - n) * width / 2 )   # leading space
 tri[n].each{|val| printf("%#{width}d", val) }
 print "\n"
end
