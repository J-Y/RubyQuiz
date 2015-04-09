s,f=1,proc{|x,y|y<1?[]:[[*s...s+=x]]+f[y-1,x].reverse.transpose}
puts f[w=gets(' ').to_i,gets.to_i].map{|i|['%3i']*w*' '%i}