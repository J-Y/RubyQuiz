# Here are my solutions to Quiz #113. For some of them I just
# couldn't help but to provide a couple variations.
# Because I'm a terrible golfer, most strive for elegance
# (in some form) over terseness.



# 1 - Commafy Numerics
i,f=quiz.to_s.split('.'); i.gsub(/(\d)(?=\d{3}+$)/,'\\1,') + (f ? ('.'+f) : '')



# 2 - Flatten_Once
a=[]; quiz.each{ |x| Array===x ? a.concat(x) : a<<x }; a



# 3 - Shuffle Array
quiz.sort_by{ rand }



# 4 - Resolve class (and other constants) from string
quiz.split( '::' ).inject( Module ){ |r,o| r.const_get(o) }
#...or, by cheating
eval(quiz) 



#5 - Paragraph Wrapping - extra work to not put a new line on the last line
quiz.gsub( /^(.{1,40})($|[ \t]+)/ ){ $2.empty? ? $1 : "#{$1}\n" }



#6 - Anagrams - assuming that the original word shouldn't be in the output...
a=[]; r=quiz.shift.split('').sort; quiz.each{|w|a<<w if w.split('').sort==r}; a
#...or, if the original word should be included
a=[]; r=quiz[0].split('').sort; quiz.each{ |w| a<<w if w.split('').sort==r }; a



#7 - String to Binary String, the geeky way
o=''; quiz.each_byte{|b| o << ( b==32 ? "\n" : ('%b' % b) ) }; o
#...or slightly more 'rubyish'...
quiz.split(' ').map{|s| o=''; s.each_byte{|b| o << b.to_s(2) }; o }.join("\n")
#...but what's more rubyish than nested #maps and pulling bytes from strings? ;)
quiz.split(' ').map{|s| s.scan(/./).map{|c| '%b' % c[0] }.join }.join("\n")

# By the way, I have to say that if the Think Geek t-shirts are really in the
# form provided, they are terrible #representations of geekiness. What geek
# would strip the leading zeros from the bits in a byte? I'd replace "%b" with
# "%08b" above for a better representation (and use it instead of to_s(2)).



#8 - Random line from file - if you run out of memory, go buy more RAM ;)
all=quiz.readlines; all[ rand(all.length) ]



#9 - Wondrous number path
a=[n=quiz]; while n>1; a << ( n%2==0 ? n/=2 : n=(n*3)+1 ); end; a



#10 - Array to Nested Hash, direct indexing...
a=quiz; h={a[-2]=>a[-1]}; (a.size-3).downto(0){ |i| h={a[i]=>h} }; h
#...or a slightly different way...
a=quiz; y,z=a[-2..-1]; h={y=>z}; a[0..-3].reverse.each{ |o| h={o=>h} }; h
#...or poppin' values for a tighter format...
a=quiz; z,y=a.pop,a.pop; h={y=>z}; a.reverse.each{ |o| h={o=>h} }; h
#...and one last, just because I love Hash.[]
a=quiz.reverse; h=Hash[a.shift,a.shift].invert; a.each{ |o| h={o=>h} }; h