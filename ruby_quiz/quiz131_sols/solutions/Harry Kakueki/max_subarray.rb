#
# Here is my solution.
# If there are multiple sub arrays that equal max sum, it prints all of them.

require 'enumerator'
arr, s = [1,5,3,-9,9], []
(1..arr.length).each{|q| arr.each_cons(q) {|x| s << x}}
big = s.max {|x,y| x.inject(0) {|a,b| a+b} <=> y.inject(0) {|c,d| c+d}}
p s.select {|r| r.inject(0) {|a,b| a+b} == big.inject(0) {|c,d| c+d}}
