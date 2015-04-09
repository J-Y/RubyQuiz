a=ARGV[0].split

pri='+-*/'

prs=[]
i=0

while a.length>1 do
  if pr=pri.index(op=a[i])
    raise if i<2
    a[i-2]='('+a[i-2]+')' if pr>>1 > prs[i-2]
    a[i-1]='('+a[i-1]+')' if pr>>1 > prs[i-1] || (pr>>1 == prs[i-1] && pr&1==1)
    a[i-2,3]=a[i-2]+op+a[i-1]
    prs[i-=2]=pr>>1
  else
    prs[i]=4
  end
  i+=1
end rescue a[0]="invalid expression"

puts a[0]
