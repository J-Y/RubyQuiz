# Here is my solution.
# I built a string to use for unpacking.
# Then I used the string to unpack.
# It should work for a blanket of any size if the
# 'colors' string is long enough.


# Code Start
colors = "GWRBYRGRRGRYBRWG"
unp = "aXaXaXaXaa"
 (1...colors.length).each do
   (1..4).each {|y| unp<<"X"<<"Xa"*(5-y)<<"a"<<"Xa"*y}
 unp << "a"
 end
row = colors.unpack(unp)
 35.times do
 puts row[0..69].join
 row.shift
 end
