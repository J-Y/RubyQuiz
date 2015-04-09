OC,OK,ERR='([{)]}',0,1
i=ARGV[0];r=OK;s=[]
i.scan(/./) { |c| 
  next if (ci=OC.index(c)).nil?
  s.push OC[ci+3].chr if ci<3
  r=ERR if ci>2 and s.pop!=c 
}
r=ERR unless s.empty?
puts i if r==OK
exit r
