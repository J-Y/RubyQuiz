seq = ARGV[0]
ops = ARGV[1]
res = ARGV[2].to_i
uops = ops.split('').uniq
print (0..(uops.length.to_s * (seq.length-1)).to_i(uops.length+1)).
map { |x| x.to_s(uops.length+1).rjust((seq.length-1), '0').
tr('012345', uops.join.ljust(6, ' ')) }.
find_all { |x| uops.inject(true){|b, op| b and (x.count(op) ==
ops.count(op))} }.
map { |x|
  t = seq[0,1] + x.split('').zip(seq[1..-1].split('')).join.delete(' ')
  [eval(t), t]
}.each { |s, x|
  puts "*****************" if s == res
  puts "#{x}: #{s}"
  puts "*****************" if s == res
}.size
puts " possible equations tested"
