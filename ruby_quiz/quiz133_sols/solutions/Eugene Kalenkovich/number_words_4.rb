# solution #4 - B16 5H0UT1N6 HACKER2

base=ARGV[1].to_i
base_=base+?a-11

raise "Bad base: [#{base}]" if base<1  || base_>?z

sub0=base_ < ?o
sub1=base>1 && base_ < ?l
sub2=base>2 && base_ < ?z
sub5=base>5 && base_ < ?s
sub6=base>6 && base_ < ?g
sub8=base>8 && base_ < ?b

reg="^["
reg<<'O' if sub0
reg<<'I' if sub1
reg<<'Z' if sub2
reg<<'S' if sub5
reg<<'G' if sub6
reg<<'B' if sub8
reg<<"|a-#{base_.chr}" if base>10
reg<<']+$'

result=File.read(ARGV[0]).split("\n").reject{|w| w !~ %r"#{reg}"i}.map{|w| 
w.upcase}.sort_by{|w| [w.length,w]}
result.map!{|w| w.gsub('O','0')} if sub0
result.map!{|w| w.gsub('I','1')} if sub1
result.map!{|w| w.gsub('Z','2')} if sub2
result.map!{|w| w.gsub('S','5')} if sub5
result.map!{|w| w.gsub('G','6')} if sub6
result.map!{|w| w.gsub('B','8')} if sub8
result.reject!{|w| w !~ /[A-Z]/} # NUM8ER5-0NLY LIKE 61885 ARE N0T READA8LE
p result
