# Commaize (works for both floats and integers)
a=quiz.to_s.split('.');a[0].reverse.gsub(/
(\d{3})/,'\1,').chomp(',').reverse+"#{'.'+a[1] if a[1]}"

# Flatten once
a=[];quiz.each{|i| if i.is_a? Array;i.each{|j| a<<j};else;a<<i;end};a

# Randomize array (the obvious way)
quiz.sort_by {rand}

# Class from String (fails for some)
begin eval "#{quiz}.allocate.class" rescue nil end

# Wrap lines (no newline at the end!)
a='';b=quiz;until b.size<=40;a<<b.slice!(0..b.rindex(' ',
40))<<"\n";end;a<<b

# Find anagrams
quiz.find_all {|x| x.split('').sort == quiz[0].split('').sort}

# Binarize
a=''; quiz.each_byte {|b| a << (b == 32 ? "\n" : "%b" % b)}; a

# Random line (kludge, reads the whole file twice)
f=quiz;c=0;f.each{c+=1};r=rand(c)+1;f.pos=0;c=0;a='';f.each{|line|c
+=1;a=line if c==r};a

# Wondrous sequence
b=quiz;a=[b];while b>1;if b%2==1;b=3*b+1;else;b=b/2;end;a<<b;end;a

# Nested hash (golf and non-golf, and my best answer (I think))
a=quiz.pop;quiz.reverse_each{|i|a={i=>a}};a
hash = quiz.pop; quiz.reverse_each { |item| hash = { item => hash } };
hash
