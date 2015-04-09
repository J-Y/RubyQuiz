happy = Hash.new do |h, k|
  sum = k.to_s.split('').inject(0) {|s, i| s + i.to_i * i.to_i}
  sum != 1 ?  (h[k] = 0) : (next h[k] = 1)
  h[k] = (h[sum.to_s.split('').sort.join.to_i].nonzero? || -1) + 1
end

puts (1..100000).max {|a, b| happy[a] <=> happy[b]}
