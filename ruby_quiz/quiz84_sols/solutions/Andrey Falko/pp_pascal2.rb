#!usr/bin/ruby
max = $*[0].to_i - 2
spaces = (3 + 3/2).ceil
row = [ 1, 1 ]
rows = 0
print " " * (2 + (max - rows + 1) * spaces/2)
print "1\n"
print " " * ((max - rows + 1) * spaces/2)
print "1  1\n"
nextRow = []
while (rows < max)
       nextRow.push(1)
       print " " * ((max - rows) * spaces/2) + "1"
       for temp in (1..(rows + 1))
               first = row.shift
               second = row.shift
               row.unshift(second)
               comb = first.to_i + second.to_i
               print "  " + comb.to_s
               nextRow.push(comb.to_i)
       end
       print "  1"
       nextRow.push(1)
       row = nextRow
       nextRow = []
       print "\n"
       rows = rows + 1
end
