#
# A set of routines to find minimal pangrams from an input set of words. A pangram is a set of 
# words that contain all the letters of the alphabet. Unless there are some properties of
# pangrams that I am unaware of, finding the minimal pangrammatic subset of a set of words
# is in a family of constraint-satisfaction problems that is NP-complete, as in, there is 
# not a way to find _the_ minimal subset that is guaranteed to run in polynomial time with respect
# to the size of the dataset. 
# 
# The most common ways of finding excellent, but not a provably perfect solution are to either
# use a non-deterministic algorithm, or to try to prune the number of subsets that you search
# as much as possible, and backtrack as often as possible.
# 
# The Pangrams class below implements both of these algorithms, providing methods to yield a
# specified number of random pangrams, or to do a backtracking search to yield successively
# better pangrams.
# 
# In order not to waste time trying non-pangrams, the strategy for building pangrams is to
# build a list by finding the least common letter not already there, and then searching for pangrams
# using the utilities containing the least-common missing letter. If at any point the string
# is longer or has more repeated characters than the known minimums then we stop searching and
# backtrack. So we abort early and try to limit the number of decisions to try at each step.
#
# The search algorithm does not run in polynomial time, but for 160 elements, it can search the
# problem space in about 30 minutes on a fast, modern machine (dual-core xeon). For larger datasets 
# (like aspell) the non-deterministic approach would be more practical.
#
# Two minimal POSIX pangrams are:
#   Minimal number of utilities: "zcat stty jobs cxref newgrp iconv cksum qhold"
#   Minimal repeated letters: "zcat tty jobs lex awk mv uniq chgrp df" (4 repeats)
#

# Takes a list of words and creates a histogram of letters. The histogram can then
# be queried for pangramness and repeated letter counts.
class LetterHistogram
  # Initializes with a set of words
  def initialize(words=nil)
    @hist = Hash.new(0)
    @total_letters = 0
    words.each {|word| add word} unless words.nil?
  end
  
  # Adds a word to the pangram
  def add(word)
    word.scan(/./) {|l| @hist[l] = @hist[l] + 1 if ('a'..'z') === l}
    @total_letters += word.size
  end
  
  # Returns true if this list of words has a pangram
  def pangram?
    return @hist.size == 26
  end
  
  # Returns the number of repeated letter
  def repeats
    @total_letters - @hist.size
  end
  
  # Returns a list of missing letters. Used in conjunction with the WordLetterMap below to 
  # find a good word to add to the list to make a pangram.
  def missing_letters
    missing = Array.new
    ('a'..'z').each {|l| missing << l if @hist[l] == 0}
    missing
  end
end

# Contans a map of Letters => Words containing that letter
class WordLetterMap
  def initialize(words)
    @map = Hash.new
    words.each {|w| add w}
  end
  
  # Adds a new word
  def add(word)
    word.scan(/./) do |l|
      if ('a'..'z') === l
        @map[l] = Array.new unless @map.has_key? l
        @map[l] = @map[l] << word
      end
    end  
  end
  
  # Return a list of words containing the least common missing letter
  # Used to limit the number of choices as we search the minimal pangram space
  def least_common(words=nil, histogram=nil)
    histogram = LetterHistogram.new words if histogram.nil?
    min_words = nil
    histogram.missing_letters.each do |l| 
      new_words = @map[l] - words
      if min_words.nil? || min_words.size > words.size
        min_words = new_words
      end
    end
    
    return min_words
  end
end

# Holds a list of words and generates minimal pangrams, both non-deterministically,
# and by searching, backtracking to avoid non-minimal branches
class Pangrams
  # Exception to throw when we have returned the maximum number of pangrams
  class AllDone < Exception
  end

  # Initialize with a word list
  def initialize(words=nil)
    if words.nil?
      @words = Array.new
    else
      @words = words
    end
  end

  # Adds a word to the set of words to produce pangrams
  def add(word)
    @words[@words.size] = word
  end
  
  # The number of words in the set of words
  def size
    @words.size
  end

  # Loads a list of words from a file
  def self.from_file(filename)
    p = Pangrams.new
    File.new(filename).each_line {|line| p.add line.strip}  
    return p  
  end

  # Yields randomly generated minimal pangrams to the passed block
  def random(count,&block)
    @word_letters = WordLetterMap.new @words
    (0..count).each {|i| random_pangram([],&block)}
  end
  
  # Searches for good minimal pangrams, yielding the ones it finds to the block
  def search(max_count=0,&block)
    @min_size = size
    @min_repeats = 1000
    @max_count = max_count
    @count = 0
    @word_letters = WordLetterMap.new @words
    begin
      pangram_search([],&block)
    rescue AllDone
      # Quit gracefully
    end
  end
  
private
  # searches the pangram space by finding all words containing the least common letter until
  # a pangram has been built, passing each found pangram to the block. The algorithm tries to 
  # be smart searching the word space by choosing the least common letters first, making the
  # overall space smaller. It also tries make smart use of backtracking to avoid searching
  # non-lucrative branches. 
  def pangram_search(words, &block)
    # Bust out if we've found enough pangrams
    raise AllDone.new if @max_count != 0 && @count > @max_count
  
    h = LetterHistogram.new words

    # If we already have more words or more repeats, then no need to look any
    # further, we should backtrack and try something else.
    return if words.size >= @min_size && h.repeats >= @min_repeats

    # This pangram is somehow minimal, so pass to the block
    if h.pangram?
      @min_size = words.size if words.size < @min_size
      @min_repeats = h.repeats if h.repeats < @min_repeats
      @count += 1
      yield words,h
      return
    end

    # No pangram yet, find children and descend
    new_words = @word_letters.least_common words,h
    new_words.each {|w| pangram_search words + [w], &block}
  end
  
  # Builds a pangram by finding the least common letter that is not represented in the
  # passed-in array, and recursing until a pangram is built. This algorithm should build
  # minimal pangrams almost all of the time (i.e. removing a word from the set will make
  # the word list non-pangrammatic and will yield very good pangrams, but probably not the
  # most optimal ones.
  def random_pangram(words, &block)    
    # Do we already have a pangram? If so, pass to block and quit
    h = LetterHistogram.new words
    if h.pangram? 
      yield words,h
      return
    end

    # Be non-deterministic, and descend on a random word
    new_words = @word_letters.least_common words,h
    new_word = new_words[rand(new_words.size)]
    random_pangram words + [new_word], &block    
  end
end
