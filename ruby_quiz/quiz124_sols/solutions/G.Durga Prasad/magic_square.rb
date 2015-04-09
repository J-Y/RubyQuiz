#!/usr/bin/env ruby
# G.D.Prasad
class Array
 def / len           # Thanks to _why
 a=[]
 each_with_index do |x,i|
 a <<[] if i%len == 0
 a.last << x
 end
 a
 end
 def rotate_left
   self.push(self.shift)
 end
 def rotate_right
   self.unshift(self.pop)
 end
end

def rotate_array_right_index_times(arrays)
 arrays.each_with_index{|array,i| i.times{array = array.rotate_right}}
end

def show(rows,n)
 string  = rows.map{|r| r.inject(""){|s,e| s + e.to_s.center(5," ")
+"|"}}.join("\n"+"-"*6*n+"\n")
 puts string
end

n=ARGV[0].to_i
raise "Usage: magic_square (ODD_NUMBER>3) " if n%2==0 or n<3
nsq=n*n
arrays = ((1..nsq).to_a/n).each{|a| a.reverse!}
sum = nsq*(nsq+1)/(2*n)
(n/2).times{arrays = arrays.rotate_left}
rotate_array_right_index_times(arrays)
cols=arrays.transpose
rotate_array_right_index_times(cols)
rows=cols.transpose

puts;puts
show(rows,n)
puts
puts "  sum of each row,column or diagonal =  #{sum}"
puts;puts
