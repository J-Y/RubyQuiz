# Return a permutation of the values (0...length) in an array.
# If "offset" is given, return [offset,...,length+offset].
# If "pad" is given, return [nil,...,nil, <rest of perm>].
# If offset == pad, you can index into the array with the
# same set of values that you get out of it.
def create_random_permutation(length, offset=0, pad=offset)
 a = Array.new(length) {|i| i + offset}
 b = Array.new(pad, nil)
 (length - 1).downto(0) {|i| b.push(a.delete_at(rand(i + 1)))}
 b
end
alias crp create_random_permutation

# Given a string, permute the characters in the interior of (a copy of) the string
# (i.e. leave the first and last characters alone) and return the result.
def permute_word(word)
 word2 = word.clone
 if word.length > 3
  p = crp(word.length - 2, 1)
  1.upto(word.length - 2) {|i| word2[p[i]] = word[i]}
 end
 word2
end

# The main program.
# Read a text file, munge all words, and write out the result.
# "Munging" means to permute all the interior letters of a word.
# The first and last letters in the word and all other characters
# (punctuation, blanks, etc.) in the string are left where they are.
# A simple filename (no path, no extension) is the argument;
# the file is assumed to be in the current directory, the input
# extension is .txt, and the output extension is .out.
def munge(name)
 infile = name + ".txt"
 outfile = name + ".out"
 line = File.open(infile) {|f| f.read}
 #i1 points at the first character in a word.
 #i2 points at the first character after a word.
 i1 = i2 = 0;
 while i1 < line.length || i2 < line.length
  i2 += 1 while i2 < line.length && line[i2, 1] =~ /[[:alpha:]]/ #in a word
  line[i1...i2] = permute_word(line[i1...i2])
  i1 = i2
  i1 += 1 while i1 < line.length && line[i1, 1] !~ /[[:alpha:]]/ #not in a word
  i2 = i1
 end
 File.open(outfile, "w") {|f| f.write(line)}
# line
end
