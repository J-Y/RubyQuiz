output, num_codes = '', 0

10.times do |x1| 10.times do |x2| 10.times do |x3|
10.times do |x4|   3.times do |x5|
    output += x1.to_s + x2.to_s + x3.to_s + x4.to_s + x5.to_s
    num_codes += 1
end end
end end end

print "number codes:  ", num_codes.to_s, "\n"
print "output length: ", output.length, "\n"
