class Array; def sum;inject(0){|s,v|s+v};end;end

def npv c,irr
 npv=0
 c.each_with_index{|c_t,t|
   npv+= c_t.to_f / (1.0+irr)**t.to_f
 }
 npv
end

def irr c, significant_digits=4
 limit = 10**-(significant_digits)
 estimate = c.sum/(c.size-1.0)/75.0
 delta = estimate.abs
 n=npv(c,estimate)
 while n.abs > limit
   sign = n/n.abs
#    p "%.6f -> %.6f"%[estimate,n]
   if (delta.abs < limit/1000)
     delta=estimate.abs               #if we aren't getting anywhere, take a big jump
     return sign/0.0 if (n-c[0]).abs < limit
   end
   estimate += (delta/=2) * sign
   n=npv c,estimate
 end
 estimate
end
