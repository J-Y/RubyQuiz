s=(s=$*.index"-s")?$*.slice!(s,2)[1].to_i: 2
d,="\21\265\22H\245\10-\0\23".unpack"B*"
f=" "
o=48
y=(0..4).map{""}
$*.join.each_byte{|z|u=d[z*7-336,7]
3.times{|x|y[x*2]<<(u[x*3]>o ?f*s+f+f:f+"-"*s+f)+f}
[1,3].map{|x|y[x]<<(u[h=x*4/3]>o ?f:"|")+f*s+(u[h+1]>o ?f:"|")+f}}
y[3,1]*=s
y[1,1]*=s
puts y
