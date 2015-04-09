dict, len = Hash.new{|h,k|h[k] = []}, ARGV[0].size
IO.foreach(ARGV[2] || 'words.txt') do |w| w.chomp!
  if w.size != len then next else s = w.dup end
  (0...w.size).each{|i|s[i]=?.; dict[s] << w; s[i]=w[i]}
end
t, known = {ARGV[1] => 0}, {}
while !known.merge!(t).include?(ARGV[0])
  t = t.keys.inject({}){|h, w|(0...w.size).each{|i|
    s=w.dup; s[i]=?.; dict[s].each{|l|h[l] = w if !known[l]}};h}
  warn 'no way!' or exit if t.empty?
end
puts w = ARGV[0]; puts w while (w = known[w]) != 0
