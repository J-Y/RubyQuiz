#!/usr/bin/ruby

def t(n, s, r)
  return 1 if n <= 1
  slice = (n.to_f/s.to_f).ceil
  s + (1.0 - (1.0-r) ** slice) * s * t(slice, s, r)
end

[100, 1000, 10000, 100000, 1000000].each do | n |
  puts "Testing for #{n} words"
  print "            "
  puts [2, 3, 4, 5, 6].map{ | s | "%10d" % s }.join('')
  [0.0001, 0.001, 0.01, 0.02, 0.03, 0.04, 0.05, 0.1].each do | r |
    print "%10.4f  " % r
    [2, 3, 4, 5, 6].each do | s |  
      print "%10.0f" % t(n, s, r)
    end
    puts
  end
  puts
end
