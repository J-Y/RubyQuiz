#!/usr/bin/ruby -w

n     = ARGV[0].to_i
wfile = ARGV[1]

w7sigs = {}
w6sigs = {}

File.open(wfile,'r') do |f|
  f.each do |line|
    next unless line.size == 8
    line.chomp!
    line.downcase!
    sig = line.unpack('aaaaaaa').sort.join("")
    next if w7sigs[sig]
    w7sigs[sig] = 1
  end
end

w7sigs.each_key do |k|
  7.times do |i|
    ns = k.dup
    ll = ns.slice!(i,1)
    w6sigs[ns] ||= []
    w6sigs[ns] << ll
  end
end

w6sigs.each {|k,v| w6sigs[k].uniq!}
w6sigs.reject!{|k,v|v.size < n}
w6sigs.sort_by{|a|a[1].size}.reverse.each do |it|
  puts "#{it[0]} #{it[1].size}"
end
__END__
