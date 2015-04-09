#!/usr/bin/env ruby
size = ARGV[0].to_i
rows = Array.new(size)
# calculate the numbers
rows[0] = [1]
(1..size - 1).each do |n|
  rows[n] = Array.new(n)
  m = 0
  rows[n - 1].inject 0 do |prev, current|
    rows[n][m] = prev + current
    m += 1
    current
  end
  rows[n] << 1
end
# longest number will be in the middle of the bottom row
max_length = rows[size - 1][size/2 - 1].to_s.length
# pad, centre and output
padded = rows.collect do |row|
  row.inject "" do |line, element|
    line + element.to_s.center(max_length + 2)
  end
end
width = padded[size - 1].length
padded.each {|row| puts row.center(width)}
