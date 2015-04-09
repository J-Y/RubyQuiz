D=IO.read('dict').split($/).grep(/^.{#{$*[0].size}}$/)
def rate(new,old,goal,l)
  t=0; v=0; new.size.times{|i|t+=1 if new[i]!=old[i]
    v+=1 if new[i]==goal[i] }
  [ 1==t && nil==l.index(new), v ]
end
def m(a,b,l)
  l << a.dup
  if a==b then p l; exit; end
  D.inject([]){|w,x| y,v = rate(x,a,b,l)
    w << [v,x] if y ; w
  }.sort.reverse_each{|v,x| m(x,b,l) }
end
m($*[0], $*[1], [])