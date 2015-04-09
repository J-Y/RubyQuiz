def c(r,i)[r,i].min==1||r==i ?1:c(r-1,i)+c(r-1,i-1)end
def g(n)(1..n).map{|i|(1..i).map{|b|c(i,b)}}end
