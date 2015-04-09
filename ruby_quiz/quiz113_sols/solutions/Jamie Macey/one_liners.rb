class OneLiner; class << self
 # Convert to string, work backwards from . (or end of string) to add commas
 def commaize(number)
   s = number.to_s; while s.gsub!(/^(-?\d+)(\d{3})([,.]\d+|$)/,
'\1,\2\3'); end; s
 end

 # Single elements appended to array, arrays added together
 def flatten_once(ary)
   a = []; ary.each{|e| e.kind_of?(Array) ? a += e : a << e }; a
 end

 # Random sort, block evaluates to 1, 0, or -1.
 def shuffle(ary)
   ary.sort{|a,b|1-rand(3)}
 end

 # Traverse class hierarchy looking up constant names
 def get_class(name)
   name.split("::").inject(Object){|klass, name| klass.const_get(name)}
 end

 # Find up to 40 chars including the space, and add a \n following.
 def wrap_text(paragraph)
   paragraph.gsub(/(.{1,39}( |$))/, "\\1\n")
 end

 # Sort the first word's chars, if current word's chars sort same, is anagram
 def find_anagrams(words)
   word = words.shift.split(//).sort; words.select{|w|w.split(//).sort == word}
 end

 # Unpack char as 8bit binary, but only grab the (important) last 7 bits
 # Would likely be easier with a sprintf %7b
 def binarize(slogan)
   slogan.split('
').map{|w|w.unpack('B8'*w.size).map{|b|b[1..7]}.join}.join("\n")
 end

 # Split lines, grab one at random
 def random_line(file)
   lines = file.read.split("\n"); lines[rand(lines.size)]
 end

 # Generate sequence, terminating on a 1
 def wondrous_sequence(n)
   a = [n]; while n != 1; n = (n%2>0) ? n*3+1 : n/2; a << n; end; a
 end
 # Recursive version, using a lambda for the recursive function
 def wondrous_sequence_r(n)
   r=lambda{|i| i==1 ? [1] : [i] + r.call((i%2>0) ? i*3+1 : i/2)}; r.call(n)
 end

 # Pop keys off the end of the array, create a new hash around it
 def nested_hash(ary)
   hsh = ary.pop; while key = ary.pop; hsh = {key => hsh}; end; hsh
 end
 # Recursive version, using a lambda for the recursive function
 def nested_hash_r(ary)
   r=lambda{|a|a.size == 1 ? a.first : {a.shift => r.call(a)}}; r.call(ary)
 end
end; end
