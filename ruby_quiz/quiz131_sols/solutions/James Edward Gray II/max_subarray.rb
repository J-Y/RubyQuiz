#!/usr/bin/env ruby -wKU

array  = [-1, 2, 3, -1, 2]
answer = (0...array.size).inject(Array.new) do |sub_arrs, i|
  sub_arrs.push(*(1..(array.size - i)).map { |j| array[i, j] })
end.map { |sub| [sub.inject(0) { |sum, n| sum + n }, sub] }.max.last

p answer
