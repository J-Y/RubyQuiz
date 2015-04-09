#!/usr/bin/ruby

include Math

def t(n, r, p)
  return 1 if n <= 1
  slices = ([2.0, n.to_f * log(1 - r) / log(p)].max).ceil
  slices + (1 - p) * slices * t(n / slices, r, p)
end

results = {}

r_samples = 256
p_samples = 1000
R_SAMPLE_POINTS = (1..r_samples).map{|r| (r.to_f / (r_samples + 1)) ** 3} 
P_SAMPLE_POINTS = (1..p_samples).map{|p| (p.to_f / (p_samples + 1))}

optimal_ps = []
[100, 1000, 10000, 100000, 1000000][4..4].each do | n |
  R_SAMPLE_POINTS.each_with_index do | r, i |
    p_opt = nil
    min_t_nrp = 1.0 / 0.0
    P_SAMPLE_POINTS.each do | p |
      t_nrp = t(n, r, p)
      (min_t_nrp = t_nrp; p_opt = p) if t_nrp < min_t_nrp
    end
    (results[r] ||= {})[n] = p_opt
    (optimal_ps[i] ||= []) << (log(1-r) / log(p_opt))
  end
end

optimal_ps = optimal_ps.sort.map { | ps | v = (ps.inject(0) { | r, p | r + p } / ps.length); (v > 1.0 ? 1.0 : ("%0.7f" % v).to_f)}
puts "OPTIMAL_FACTORS = #{optimal_ps.inspect}"  # ##{optimal_ps.inspect.scan(/.{0,160}(?:,|\])/).join("\n  ")}"

# _ _ END _ _

print "     r,".ljust(10)
results.sort[0][1].sort.each do | n, p |
  print "%10d," % n
end
puts

results.sort.each do | r, row |
  print "%9.4f," % r
  row.sort.each do | n, p |
    print "%10.4f," % p
  end
  puts
end
