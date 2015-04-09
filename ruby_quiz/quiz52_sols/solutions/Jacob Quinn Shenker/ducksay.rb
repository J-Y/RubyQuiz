######################
#!/usr/bin/env ruby
# ~383 chars
# y = "eye"
# m = "beak/mouth"
# z = "balloon tail"
# f = "text" (defaults to fortune)
y="º"[0..1];m=">"[0..1];z="\\";w=40;N="\n";BS="\\"+N;S="
";f=`fortune`.split(N);e=f.collect{|v|v.split(/\s+/)};t="
#{"_"*w}\n/"+S*w+BS;while e.size>0;l="|";d=e.shift;while
d.size>0;while d.size>0&&(l+d.first).length<w;l+=d.shift+S;end;t+=l+S*(w-l.length+1)+"|"+N;l="|";end;end;t+="\\#{'_'*w}/"+N;h=S*3+z+N;b=S*5+"`
#{m}(#{y})____,\n"+S*8+"(` =~~/\n"+"^~"*5+"`---'"+"^~"*30;puts t+h+b
#######################
