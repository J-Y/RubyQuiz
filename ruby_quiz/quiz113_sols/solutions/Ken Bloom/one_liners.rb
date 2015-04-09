#In all of this, +i+ is the input. Some solutions don't behave exactly the same as the requested sample output, and some are too long. I think I noted all such instances.

# * Given a Numeric, provide a String representation with commas inserted between
# each set of three digits in front of the decimal.  For example, 1999995.99
# should become "1,999,995.99".

#this takes 83 characters
i,f=i.to_s.split('.');"#{i.reverse.scan(/.{1,3}/).join(',').reverse}.#{f}"
quiz.to_s.gsub(/(\d)(?=\d{3}+#{quiz.to_s=~/\./?/\./:/$/})/,'\\1,')

# * Given a nested Array of Arrays, perform a flatten()-like operation that
# removes only the top level of nesting.  For example, [1, [2, [3]]] would become
# [1, 2, [3]].

i.inject([]){|cur,val| Array===val ? cur+val : cur << val}
#or
i.inject([]){|cur,val| cur+val rescue cur << val}
#(cur+val throws an error if val isn't an array)

# * Shuffle the contents of a provided Array.

i.inject([]){|cur,val| cur.insert(rand(cur.length+1),val)}

# * Given a Ruby class name in String form (like
# "GhostWheel::Expression::LookAhead"), fetch the actual class object.

eval(i)
#or
i.split("::").inject(Object){|c,v| c.const_get(v)}

# * Insert newlines into a paragraph of prose (provided in a String) so
# lines will wrap at 40 characters.

#clearly doesn't fit within 80 characters
i.split.inject([[]]){|r,w| (r[-1].inject(0){|a,b| a+b.size}+w.size)<40 ? r[-1] << w : r << [w]; r}.map{|x| x.join(' ')}.join("\n")


# * Given an Array of String words, build an Array of only those words
# that are  anagrams of the first word in the Array.

i.select{|x| x.split(//).sort==i.first.split(//).sort}

# * Convert a ThinkGeek t-shirt slogan (in String form) into a binary
# representation (still a String).  For example, the popular shirt "you are dumb"
# is actually printed as:
# 
# 	111100111011111110101
# 	110000111100101100101
# 	1100100111010111011011100010

i.unpack("B*")[0]
#this doesn't give me the same answer that you gave me though
#or
r="";i.each_byte{|x| r << x.to_s(2)};r

# * Provided with an open File object, select a random line of content.
x=i.readlines;x[rand(x.length)]
#or
i.find{rand<.0005 || i.eof?}
#the rules didn't say anything about the random distribution used.
#adjust the threshold as necessary

# * Given a wondrous number Integer, produce the sequence (in an Array).  A
# wondrous number is a number that eventually reaches one, if you apply the
# following rules to build a sequence from it.  If the current number in the
# sequence is even, the next number is that number divided by two.  When the
# current number is odd, multiply that number by three and add one to get the next
# number in the sequence.  Therefore, if we start with the wondrous number 15, the
# sequence is [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2,
# 1].

r=[i];while i!=1 do r << (i= i%2==0?i/2:i*3+1); end; r

# 
# * Convert an Array of objects to nested Hashes such that %w[one two three four
# five] becomes {"one" => {"two" => {"three" => {"four" => "five"}}}}.

#neither of these gives the same answer asked for here
p=lambda{|h,k| h[k] = Hash.new(&p)};z=Hash.new(&p);i.inject(z){|ha,co|ha[co]};z
#or
z={};i.inject(z){|ha,co| ha[co]={}};z
#or
(h=lambda {|n| n==1 ? [1] : [n] + h[n%2 == 0 ? n/2 : n*3+1] })[quiz]
