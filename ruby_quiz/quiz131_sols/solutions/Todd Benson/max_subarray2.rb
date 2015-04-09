a = Array.new(42){rand(42)-21}

v=[]
0.upto(b=a.size-1){|i|i.upto(b){|j|v<<a[i..j]}}
p v.inject([a.max]){|z,m|z.inject{|s,i|s+i}>m.inject{|s,i|s+i}?z:m}
