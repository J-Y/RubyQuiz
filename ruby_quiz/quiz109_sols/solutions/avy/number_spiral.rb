n = (ARGV[0] || 8).to_i
(0...n).each do |row|
  lev = (row-n/2).abs
  m = [2*lev+1,n].min
  p = (n-m+1)/2
  (0...p).each do |col|
    s = (n/2-col)*2
    s = s*(s-1)-(row-col)
    printf "%2d ",s
  end
  delta = n/2<=>row
  s = lev*2
  s *= (s-delta)
  s += m-1 if delta<0
  m.times do
    printf "%2d ",s
    s += delta
  end
  (0...n-p-m).each do |col|
    s = (lev+col+1)*2
    s = s*(s+1)-(p+m+col-row)
    printf "%2d ",s
  end
  puts
end
