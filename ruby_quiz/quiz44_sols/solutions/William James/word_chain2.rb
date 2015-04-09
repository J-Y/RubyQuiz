dict = Hash.new{|h,k| h[k] = [] }
IO.foreach($*[2] || 'words.txt') do |w| w.chomp!
  next if w.size != $*[0].size
  w.size.times{|i| dict[w[0,i]+"."+w[i+1..-1]] << w}
end
t, known = {$*[1], 0}, {}
while !known.merge!(t).key?($*[0])
  t = t.keys.inject({}){|h, w| (0...w.size).each{|i| s=w.dup
    s[i]=?.; dict[s].each{|l| h[l] = w if !known[l] }}; h }
  warn 'no way!' or exit if t=={}
end
puts w = $*[0]; puts w while (w = known[w]) != 0
