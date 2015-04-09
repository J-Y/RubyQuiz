#!/usr/bin/env ruby
def center_str s, len
  n = (len - s.length) / 2.0
  ' '*(n.floor) + s + ' '*(n.ceil)
end

n = ARGV[0].to_i
rows = [[1]]
for i in 1..(n)
  k = -1; r = rows[i-1] + [0]
  rows << r.map{ |x| j = k; k+=1; x + r[j] }
end
m = rows.last[n/2].to_s.length * 2
n = rows.last.length * m
rows.each do |r|
  puts center_str(r.collect{|x| center_str(x.to_s, m)}.join, n)
end
