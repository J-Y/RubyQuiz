puts (0...ARGV.first.to_i).inject([[1]]) { |a,x|

  a.unshift a.first.inject([0,[]]) { |b,y|
      [y,b.last << (b.first + y)]
  }.last + [1]
}.inject([]) { |c,z|
  next [z[z.length/2].to_s.length*2,z.length,""] if c.empty?
  [c[0],c[1], z.map { |j|
          j.to_s.center(c[0])
      }.join('').center(c[0]*c[1])+"\n#{c.last}"]
}.last
