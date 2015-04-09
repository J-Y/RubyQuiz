target = ARGV[0]
dict = ARGV[1] || 'sowpods'

reduced = target.split(//).sort.uniq.join
primes = [2, 3, 5, 7, 11, 13]
factors = []
reduced.split(//).each_with_index {|e, i|
 factors[e[0]] = primes[i]
}

target_num = 1
target.each_byte {|i| target_num *= factors[i]}

IO.foreach(dict) {|word|
 word.chomp!
 next unless (word =~ /^[#{reduced}]+$/) &&
   (word.length < 7) && (word.length > 2)
 p = 1
 word.each_byte {|i| p *= factors[i]}
 puts word if target_num % p == 0
}
