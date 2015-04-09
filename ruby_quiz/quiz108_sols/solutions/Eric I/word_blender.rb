# Given an array of letters, a whole/partial word built up so far, and
# a hash, adds to the hash all permutations of subsets built from the
# partial word and the array of letters.  If a block is given it acts
# as a filter since the words must produce a true result when submitted
# to the block in order to be added to the hash.
def permute(letters, word, possible_words, &filter_block)
  possible_words[word] = true if filter_block.nil? || filter_block.call(word)
  return if letters.empty?

  letters.each_with_index do |letter, i|
    (new_letters = letters.dup).delete_at(i)
    permute(new_letters, word + letter, possible_words, &filter_block)
  end
end

# Verify that a filename was provided as the first argument and that
# it is a readable file
if ARGV[0].nil?
  $stderr.puts("Usage: #{$0} dictionary-file [word]")
  exit 1
elsif ! File.file?(ARGV[0]) || ! File.readable?(ARGV[0])
  $stderr.puts("Error: \"#{ARGV[0]}\" is not a readable file.")
  exit 2
end

# Build list of all six-letter words from dictionary file
words6 = Array.new
open(ARGV[0], "r") do |f|
  f.each_line { |w| words6 << w if w.chomp! =~ /^[a-z]{6}$/ }
end

# Determine whether a random six-letter word is chosen or the user
# specifies one.
if ARGV[1]
  # user attempted to specify a word; check its validity
  if words6.include?(ARGV[1])
    word = ARGV[1]
  else
    $stderr.puts("Error: \"#{ARGV[1]}\" is not a known six-letter word.")
    exit 3
  end
else
  word = words6[rand(words6.size)]  # choose a random word
end

# Generate a hash of all three- to six-letter permutations using the
# letters of the chosen six-letter word.  Note: most will not be valid
# words.
possible_words = Hash.new
permute(word.split(""), "", possible_words) { |w| w.length >= 3 }

# Generate a list of all valid words that are also permutations of
# subsets of the chosen six-letter word.  This is done by
# re-reading the word file and testing each word against the
# possible permutations.
actual_words = Array.new
open(ARGV[0], "r") do |f|
  f.each_line { |w| actual_words << w if possible_words[w.chomp!] }
end

# Display the resulting actual words sorted first by length and then
# alphabetically.
puts actual_words.sort_by { |w| [w.length, w] }
