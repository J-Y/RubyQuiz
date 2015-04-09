#! /usr/bin/ruby

# Copyright (C) 2004 Hans Fugal
# Distributed under the GPL

require 'set'

# this function sorts the letters, so e.g. "ruby" becomes "bruy". This will
# give us a standard representation of an "anagram"
def parse_anagram(word)
  word.split("").sort.join
end

# get n
n = ARGV[0] ? ARGV[0].to_i : 1

# pull in the wordlist. We're only interested in 7-letter words and we'll
# anagram-ize them so we end up with unique 7-letter anagrams.
$stderr.print "Parsing wordlist on stdin..."
$stderr.flush
anagrams = Set.new
$stdin.each_line do |word|
  word.downcase!
  word.tr!("^a-z","")
  next unless word.size == 7
  anagrams.add(parse_anagram(word))
end
$stderr.puts " #{anagrams.size} unique 7-letter anagrams loaded."


# Now for the real fun. Initially I generated the 6-letter stems, added
# letters, and tested for the resulting anagram in the anagram list. That took
# way too long. Then I realized it would be _much_ more efficient to work
# backwards, going from known 7-letter anagrams to 6-letter anagrams by
# subtraction. VoilÃ¡, many orders of magnitude faster.
$stderr.print "Generating 6-letter stems from anagrams..."
$stderr.flush
stems = Hash.new {|h,k| h[k] = ""}
anagrams.each do |a|
  a.size.times do |i|
    stem = parse_anagram a[0,i]+a[i+1..-1]
    letters = stems[stem]
    letters << a[i] unless letters.include? a[i]
  end
end
$stderr.puts " #{stems.size} stems generated."

# The boring part. Print out the answers and apply the cutoff n.
stems.sort_by {|kv| kv[1].size}.reverse.each do |kv| 
  size = kv[1].size
  puts "#{kv[0]}\t#{size}" if size >= n
end
