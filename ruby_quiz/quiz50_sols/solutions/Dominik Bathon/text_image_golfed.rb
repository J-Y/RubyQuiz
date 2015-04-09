f=open$*[0],"rb";w,h=f.read(54)[18,8].unpack"VV"
puts((1..h).collect{(1..w).collect{"DY8S65Jjtc+i!;:."[f.read(3).unpack(
"CCC").inject{|a,b|a+b}/48,1]}.join}.reverse)
