require 'rubygems'
require 'multi'

SEP = ' '*3; rows = (ARGV[0] || 10).to_i

multi(:pascal, [1])    { [1] }
multi(:pascal, [2])    { [1, 1] }
multi(:pascal, Array)  { |a| result=[1]; 0.upto(a.length-2){ |i| result << a[i]+a[i+1] }; result+[1] }

last, triangle = [], []
rows.times { |n| triangle << last = (n<2) ? pascal([n+1]) : pascal(last) }
len = triangle[-1].join(SEP).length
triangle.map { |row| c = row.join(SEP); puts ' '*((len - c.length) / 2) << c }
