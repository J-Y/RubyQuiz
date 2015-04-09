# puzzles.rb
# generate puzzles for use by wordblend.rb program
#
# usage: ruby puzzles.rb >puzzles.dat

require 'open-uri'
require 'yaml'

# these urls point to text files with lists of 2000 commonest
# English word "families", including plurals and other forms.
# this ends up generating reasonably good puzzles.
URIS = %w{
 http://www1.harenet.ne.jp/~waring/vocab/wordlists/full1000.txt
 http://www1.harenet.ne.jp/~waring/vocab/wordlists/full2000.txt
}

# minimum number of words necessary to form a puzzle
MIN_SIZE = 6

# define some helper functions
class String

 # returns string with characters in sorted order
 def sort
   split(//).sort.join
 end

 # returns true if s is a subword of the string. both
 # the string and s must be sorted!
 def subword?(s)
   i = j = 0
   while j < s.length
     i += 1 while i < length and self[i] != s[j]
     i < length or return false
     j += 1
     i += 1
   end
   true
 end

end

# grab the 3-6 letter words from word lists. sort each word by
# character (e.g. 'test' becomes 'estt'), and then accumulate
STDERR.puts "Fetching words..."
words = Hash.new {|h,k| h[k] = []}
URIS.each do |uri|
 open(uri) do |f|
   f.read.split.select {|w| w.length >= 3 and w.length <= 6}.each do |word|
     word.upcase!
     sword = word.sort
     words[sword] << word
   end
 end
end

# find puzzles by looking at which sorted words are contained in
# other six-character sorted words.
STDERR.puts "Finding puzzles..."
n = 0
words.keys.select {|w| w.length == 6}.each do |key|
 puzzle = words.select {|ssub, subs| key.subword?(ssub)}.collect {|a|
a.last}.flatten.sort_by {|w| "#{w.length}#{w}"}
 next if puzzle.size < MIN_SIZE
 puts puzzle.join(':')
end
