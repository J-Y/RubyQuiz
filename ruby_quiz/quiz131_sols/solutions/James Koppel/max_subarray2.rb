p (b=(0...(l=a.size)).to_a).zip([b]*l).map{|(i,s)|s.map{|j|a[i,j]}}.sort_by{|a|a.map!{|a|[a.inject(0){|s,n|s+n},a]}.sort![-1][0]}[-1][-1][-1]
