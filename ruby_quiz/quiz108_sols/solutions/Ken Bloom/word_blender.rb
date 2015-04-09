require 'rubygems'
require 'facets/core/enumerable/permutation'
require 'set'

#usage: texttwist [word]
# specifying a word will use /usr/share/dict/words to solve a TextTwist 
# problem. If no word is specified, a random word will be selected, to
# generate an round of texttwist.

#load dictionary
matcher=Set.new
allwords=Array.new
open("/usr/share/dict/words") do |f|
   f.each do |line|
      line.chomp!
      next if line !~ /^[a-z]+$/
      matcher << line if line.length<=6
      allwords << line if line.length==6
   end
end

#generate subwords of a word
word=ARGV[0] || allwords[rand(allwords.length)]
thiswordmatcher=Set.new
word.split(//).each_permutation do |perm|
   perm=perm.join
   (3..6).each do |len|
      candidate=perm[0,len]
      if matcher.include?(candidate)
	 thiswordmatcher << candidate
      end
   end
end

#output
puts word
puts "======"
thiswordmatcher.each do |subword|
   puts subword
end
