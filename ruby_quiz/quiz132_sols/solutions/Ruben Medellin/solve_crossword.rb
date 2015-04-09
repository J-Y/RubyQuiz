DICTIONARY = {}
class << DICTIONARY
  def <<(word)
    (self[word.size] ||= []) << word
  end
end

File.open('/usr/share/dict/words', 'r') do |file|
  while (word = file.gets)
    word = word.strip.upcase
    next if word =~ /[^A-Z]/
    DICTIONARY << word 
  end
end

require 'matrix'

CLEAR = "\e[H\e[2J"

# DRY
class Array
  def pick_random
    self[rand(size)]
  end
end

# Since strings are copied by value, I created this class that represents
# a square of the board ( a letter )
class Square
  
  attr_accessor :letter
  
  def initialize(letter)
    @letter = letter
  end
  
  def to_s
    @letter == '#' ? ' ' : @letter.to_s
  end
  
  alias inspect to_s
  
end

# Class that represents an Array of Squares, that is, the
# squares of a word in particular
class WordArray < Array
  
  attr_accessor :crossed, :banned, :cached_possibilities
  
  # Checks if writing a letter in the specified index leaves
  # possible words.
  def is_possible?(letter, index)
    possibilities = DICTIONARY[size]
    each_with_index do |ltr, i|
      next if ltr.letter == '_'
      possibilities = possibilities.select {|p| p[i].chr == ltr.letter }
    end
    possibilities = possibilities.select {|p| p[index].chr == letter}
    possibilities -= @banned
    @cached_possibilities = possibilities
    !possibilities.empty?
  end
  
  def initialize
    @last_written = []
    @banned = []
  end
  
  # Will erase the last word written, without affecting previous letters
  def takeback
    @last_written.each{ |letter| letter.letter = '_' }
  end
  
  # Adds the word to the list of banned words.
  def ban(word)
    @banned << word
  end
  
  # Empties list of banned words.
  def unban
    @banned.clear
  end
 
  # True if all letters have been written
  def filled?
    all?{|letter| letter.letter != '_' }
  end
  
  # Places each letter in its corresponding square.
  # Also, remembers which letters were written.
  def write(word)
    @cached_possibilities = nil
    @last_written = []
    for i in 0...size
      if self[i].letter == '_'
        self[i].letter = word[i].chr
        @last_written << self[i]
      end
    end
  end
  
  alias get_word join
  
end

# The main class. Consists of a matrix of squares.
class CrossWord < Matrix
  
  attr_accessor :words
  
  def get_rows
    @rows
  end
  
  def to_s
    puts CLEAR
    @rows.inject(''){|str, row| str + row.join(' ') + "\n" }
  end
  
  alias inspect to_s
  
  # Gets an array containing all words to be filled.
  def get_words
    words = []
    cache = WordArray.new
    
    [get_rows, CrossWord[*transpose].get_rows ].each do |matrix|
      matrix.each do |array|
        array.each do |letter|
          break_word = (letter.letter == '#')
          if break_word
            words << cache unless cache.size <= 1
            cache = WordArray.new
            break_word = false
            next
          else
            cache << letter
          end
        end
        words << cache unless cache.size <= 1
        cache = WordArray.new
      end
    end
    @words = words
    retrieve_crossings
    sorted_words = []
    sorted_words << (words.shift)
    breadth_search(words, sorted_words)
    sorted_words
  end
  
  # Auxiliar method to sort the words.
  def breadth_search(word_array, sorted)
    return if word_array.empty?
    next_words = sorted.last.crossed.select{|w| word_array.include?(w)}
    unless next_words.empty?
      sorted.push( *next_words )
      next_words.each{|w| word_array.delete(w)}
    else
      sorted << (word_array.shift)
    end
    breadth_search(word_array, sorted)
  end
  
  # Relates each word with the ones that are crossed by it.
  def retrieve_crossings
    @words.each do |word|
      word.crossed = (@words.select {|w| !(word & w).empty? } - [word])
    end
  end
  
  # Will try to pick a word. It will check if leaves options to the words
  # that cross it, and will avoid banned words.
  def pick_word_for(word)
    
    # If there are many banned words, probably they are too similar,
    # hence is not a very good option.
    if word.banned.size > 5
      word.crossed.each{|w| w.cached_possibilities = nil; w.unban unless w.filled? }
      return nil
    end
    
    crossed = word.crossed
    
    if word.cached_possibilities
      possibilities = word.cached_possibilities
    else
      possibilities = DICTIONARY[word.size]
      word.each_with_index do |ltr, i|
        next if ltr.letter == '_'
        possibilities = possibilities.select {|p| p[i].chr == ltr.letter }
      end
    end
    possibilities -= word.banned
    
    # Will try 20 times at most to select a possible word.
    tries = 0
    until possibilities.empty?
      return nil if (tries += 1) > 20
      
      # Will check if the word is possible
      possible_word = possibilities.delete(possibilities.pick_random)
      not_possible = false
      word.each_with_index do |letter, i|
        new_word = crossed.find{|n| n.include?(letter)}
        next unless new_word 
        next if new_word.filled?
        new_index = new_word.index(letter)
        unless new_word.is_possible?( possible_word[i].chr, new_index)
          possibilities = possibilities.select{|p| p[i].chr != possible_word[i].chr}
          not_possible = true
          break
        end
      end
      
      if not_possible
        crossed.each{|w| w.cached_possibilities = nil; w.unban unless w.filled? }
        word.cached_possibilities = nil
        next
      else
        return possible_word
      end
      
    end
    
    # Not enough possibilities
    return nil
    
  end
  
  # Main code to fill a crossword
  def CrossWord.fill(format)
    
    board = CrossWord[* format.split.map{|row| row.split('').map{|e| Square.new(e)} }]
    words = board.get_words
    
    filled = []
    
    initial_word = board.pick_word_for(words[0])
    words[0].write( initial_word )
    
    filled << words.shift
    
    puts board
    
    until words.empty?
      next_word = words.find{|w| !(filled.last & w).empty? } || words.first
      next_guess = board.pick_word_for(next_word)
      if next_guess
        next_word.write(next_guess)
        filled << words.delete(next_word)
      else
        #Will do a takeback
        to_takeback = []
        to_takeback << (last = filled.pop)
        # Will takeback to the word that causes the problem
        until last.crossed.include? next_word
          to_takeback << (last = filled.pop) 
        end
        last.ban(last.get_word)
        to_takeback.each do |w|
          w.takeback
          words.unshift(w)
        end
        # To prevent banning the possibilities for the initial word
        last.unban if last == initial_word
      end
      
      puts CLEAR, board
      sleep(0.2)
    end

    puts board
  end
  
end

#### BEGIN TESTS ####

crossword1 = <<CROSSWORD
_____
_#_#_
_____
_#_#_
_____
CROSSWORD

crossword2 = <<CROSSWORD
____#_________#____
_#_#_#_#_#_#_#_#_#_
_________#_________
_#_#_#_#___#_#_#_#_
#____#_#_#_#_#____#
_#_###_______###_#_
______##_#_##______
_#_##_#_____#_##_#_
________#_#________
_##_#_#_____#_#_##_
________#_#________
_#_##_#_____#_##_#_
______##_#_##______
_#_###_______###_#_
#____#_#_#_#_#____#
_#_#_#_#___#_#_#_#_
_________#_________
_#_#_#_#_#_#_#_#_#_
____#_________#____
CROSSWORD

crossword3 = <<CROSSWORD
__________#__________
_###_######_##_#_###_
_###_____##_##___###_
_###_#_#_##_##_#_###_
_____#______##_#_____
_#_#####_##____###_#_
______##_##_#_##___#_
_####_______#_##_#_#_
_####_#####_#______#_
____________#_##_###_
####_##_#_#_#_##_####
_###_##_#____________
_#______#_#####_####_
_#_#_##_#_______####_
_#___##_#_##_##______
_#_###____##_#####_#_
_____#_##______#_____
_###_#_##_##_#_#_###_
_###___##_##_____###_
_###_#_##_######_###_
__________#__________
CROSSWORD

[crossword1, crossword2, crossword3].each{ |cw| CrossWord.fill(cw) }