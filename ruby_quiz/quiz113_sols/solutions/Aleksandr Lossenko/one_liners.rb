# 1) Anagrams (considering that the first word is also an anagram of itself)
# delete every string that is not anagram of the first string
quiz.delete_if {|x| x.split('').sort.join != quiz[0].split('').sort.join}

# 2) Convert an Array of objects to nested Hashes
# pop 2 elements, make a hash from them, and push the hash back. when there is only 1 element, the hash is ready 
quiz << {quiz.pop => quiz.pop}.invert while(quiz.length >1); quiz.pop

# 3) Provided with an open File object, select a random line of content.
# lineno gives the number of lines. use the random function and get the line 
quiz.readlines[rand(quiz.lineno)]

# 4) Shuffle array
# take a random element and push it to the top
quiz.size.downto(1) { |n| quiz << quiz.delete_at(rand(n)) };

# 5) wondrous number
# start with the array containing the first wondrous number and go from there 
a=[quiz]; a << (a.last%2==1 ? a.last*3+1 : a.last/2) while a.last!=1
