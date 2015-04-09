def c(r,i)[r,i].min==1||r==i ?1:c(r-1,i)+c(r-1,i-1)end
def d(n)w=Math.log10(c(n,n/2)).ceil+1;(0..n).map{|z|print "
"*((n-z)*w/2);(1..z).map{|b|printf("%#{w}d",c(z,b))};puts}end
d(5)
