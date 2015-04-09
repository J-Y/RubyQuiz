f=proc{|n|n>1?n*f[n-1]:1} # Factorial
c=proc{|r,i|f[r]/(f[i]*f[r-i])} # Compute cell[r(ow),i(ndex)]
t,rows,B,S=[],(ARGV[0]||10).to_i,10,' '; W=c[rows-1,rows/2].to_s(B).length # Init vars
rows.times{|r|l=[];(r+1).times{|i|l<<(((s=c[r,i].to_s(B)).length<W)?S*(W-s.length)+s:s).upcase};t<< l}
tl=t[-1].join(' ').length; t.map{|r|c=r.join(' ');puts ' '*((tl-c.length)/2)<< c} # Display result
