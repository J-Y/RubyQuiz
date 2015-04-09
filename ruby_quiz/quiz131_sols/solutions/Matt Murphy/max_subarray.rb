require 'set'
a = [-1, 2, 5, -1, 3, -2, 1]
min = 0
max = a.size - 1

subs = Set.new

(min..max).each do |x|
  (min..max).each do |y|
    subs << a[x,y]
    subs << a[y,x] 
  end
end

puts subs.sort_by{|arr| arr.inject(0){|sum,element| element + sum } }.reverse.first.inspect