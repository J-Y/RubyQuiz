fac	= lambda{|n| n < 2 ? 1 : (1..n).inject{|f, i| f * i}}
tri	= lambda{|n, r| fac[n] / (fac[r] * fac[n-r])}
size	= lambda{|r| tri[r-1, r / 2].to_s.size + 1}
line	= lambda{|y, r| (0..y).map{|x| tri[y,x].to_s.center size[r]}}
lines	= lambda{|r| (0...r).map{|y| line[y, r]}}
pascal	= lambda{|r| lines[r].map{|l| l.join.center(size[r]*r).rstrip}}

cache	= lambda{|f| h={} ; lambda{|*args| h[args] ||= f[*args]}}

fac	= cache[fac]
tri	= cache[tri]
size	= cache[size]
line	= cache[line]
lines	= cache[lines]
pascal	= cache[pascal]

puts pascal[(ARGV[0] || 15).to_i]
