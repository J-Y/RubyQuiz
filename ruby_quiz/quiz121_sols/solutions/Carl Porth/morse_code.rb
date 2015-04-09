#!/usr/bin/env ruby -wKU

require "set"

WORD_FILE = "/usr/share/dict/words"
MORSE_LETTERS = %w[.- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. --
  -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --..]

# map encodings to letters
ENCODINGS = Hash[*MORSE_LETTERS.zip(('A'..'Z').to_a).flatten]

def morse_decodings(word)
  # iterate through matching prefixes
  ENCODINGS.select { |p,l| p == word[0,p.size] }.map do |prefix,letter|

    # gather decoded suffixes for the current prefix
    suffixes = morse_decodings( word[prefix.size,word.size] )

    # append decoded suffixes to decoded letter
    suffixes.empty? ? letter : suffixes.map { |s| letter + s }

  end.flatten
end

decodings = morse_decodings(readline.chomp).sort

puts "All Possible Decodings:"
decodings.each { |e| puts e }

# read word file into set (for fast indexing)
words = Set.new
open(WORD_FILE).each { |line| words << line.chomp.upcase }

puts "All Decodings in Dictionary:"
decodings.each { |e| puts e if words.include? e }
