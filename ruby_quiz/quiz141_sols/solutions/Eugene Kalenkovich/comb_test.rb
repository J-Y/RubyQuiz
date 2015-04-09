require 'benchmark'

def f(n) (2..n).inject(1){|s,n| s*n } end
def perm(m,n) f(m)/(f(n)*f(m-n)) end  # not pern[utations] at all, combinations

def comb(m,n)
  num,denum=m,1;
  (2..n).each{|i| num*=(m-i+1); denum*=i}
  num/denum
end

n=5000;
choices=500;
tests=[]
n.times { a=rand(choices+1); tests<<[a,rand(a)]}

Benchmark.bm do |x|
  x.report("pern") { tests.each{|a| perm(a[0],a[1])} }
  x.report("comb") { tests.each{|a| comb(a[0],a[1])} }
end
