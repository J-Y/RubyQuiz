happy = Hash.new do |h, k|
 digits = k.to_s.split('')
 digits_sorted = digits.sort
 next h[k] = h[digits_sorted.join.to_i] if digits != digits_sorted
 sum = digits.inject(0) {|s, i| s + i.to_i * i.to_i}
 sum != 1 ? (h[k] = 0) : (next h[k] = 1)
 h[k] = (h[sum].nonzero? || -1) + 1
end

puts (1..100000).max {|a, b| happy[a] <=> happy[b]}
