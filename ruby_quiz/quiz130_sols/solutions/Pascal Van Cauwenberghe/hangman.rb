require 'rubygems'
gem 'rspec'
require 'spec'

# The HangMan classes don't bother with UI. I was more interested in the strategies that could be used
# The experiment consists of playing the game on +/- 20900 English words of 5 letters or more and
#  plotting how many wrong guesses are made. The player has the dictionary.

# The first strategy I thought of was a classic 'Binary chop': find the letter that appears in about half
#  of the words. Thereby, you eliminate half of the words from the dictionary, whatever the outcome. 
# This strategy succeeds in guessing the right word with 5 or fewer wrong guesses in 86% of cases
# This is implemented in MidpointStrategy
#
# But this is not a symmetrical problem: we're not optimizing the number of guesses, but the number of wrong guesses.
# Also, a correct guess gives us more information than a wrong guess: we get the position(s) of the correct letter.
#  This allows us to eliminate even more words.
# The ThreeQuarterpointStrategy chooses the letter that is present in about 3/4 of the words.
# This strategy succeeds in 94 % of cases.
#
# The MostFrequentStrategy chooses the letter that appears in most words. This strategy succeeds in almost 95% of cases.
#
# The EnglishFrequencyStrategy is much simpler: it doesn't take advantage of the dictionary. It just guesses letters
#  based on their frequency in English words. This strategy is faster than the others but does poorly: 11% success
#
# The results can be seen at http://blog.nayima.be/wp-content/uploads/hangman-strategies.JPG

# The code is mostly self-explanatory. I've had to cache a few things (letters in Words, the number of words that contain a letter)
#  to speed things up. The simulation plays about 1100 games per minute
#
# The tests use a file words.txt that I copied from /usr/share/dict/words
# Each line of the file contains one word
# This file can be downloaded from http://blog.nayima.be/wp-content/uploads/words.txt

module RubyQuiz


  # A Word describes a word in the dictionary
  # For optimization, the word keeps an array of all unique letters in the word
  class Word
    attr_reader :word
    attr_reader :letters

    # Create a word with the given string
    def initialize(word)
      @word = word
      @letters = unique_letters_in(word)
    end

    private

    def unique_letters_in(word)
      bytes = []
      word.each_byte {|c| bytes << c }
      bytes.uniq
    end
  end

  # The Dictionary contains a list of words  
  class Dictionary

    # Create an empty dictionary
    def initialize
      change_wordlist []
      @dictionary_per_size = {}
    end

    # Add one word to the dictionary
    def add(word)
      change_wordlist(@words + [ Word.new(word) ] )
    end

    # Load all words from a text file (one word per line)
    # Keep only words that are 5 ascii letters or more
    # Words all all lower case
    def load(file)
      words = File.readlines(file)
      words = words.collect {|word| Word.new(word.chomp.downcase) }
      change_wordlist(words.select {|word| word.word.length >= 5 && word.word =~ /^([a-z])+$/ })
      self
    end

    def dup
      other = super
      other.add_words(@words)
      other
    end

    # Return a new Dictionary with only the words of the given length
    def with_only_words_of_size(len)
      other = Dictionary.new
      @dictionary_per_size[len] ||= @words.select{|word| word.word.length == len }
      words = @dictionary_per_size[len] 
      other.add_words(words)
      other
    end

    # Number of Words
    def length
      @words.length
    end

    # Access each Word individually
    def [](index)
      @words[index].word
    end

    # Filter out all words that don't have the given length
    def keep_only_words_of_length(len)
      change_wordlist(@words.select{|word,letters| word.word.length == len })
    end

    # Filter out all words that contain the given letter
    def reject_words_that_contain(letter)
      change_wordlist(@words.select { |word,letters| word.word.index(letter) == nil })
    end

    # Keep only the words that match the partial solution
    def keep_only_words_that_match(hangman_pattern)
      pattern = Regexp.new('^' + hangman_pattern.gsub(/-/,'.') + '$')

      change_wordlist(@words.select { |word,letters| word.word =~ pattern })
    end

    # Return the number of words in the dictionary that contain the given letter
    def words_that_contain(letter)
      letter_count(letter)
    end

    # Iterate over each Word
    def each(&block)
      @words.each(&block)
    end


    protected

    def add_words(words)
      change_wordlist(words)
    end

    private

    def change_wordlist(list)
      @words = list
      @letter_counts = nil
      @dictionary_per_size = {}
    end

    # Compute the number of words that a letter appears in
    # Because this is an expensive operation, cache the results. The cache is invalidated when the list of Words changes
    def letter_count(letter)
      @letter_counts ||= compute_counts
      @letter_counts[letter[0] - ?a]
    end

    def compute_counts
      count = Array.new(26,0)
      @words.each do |word|
        word.letters.each {|c| count[c-?a] += 1}
      end
      count
    end
  end

  # Guess the letter that appears in most words
  class MostFrequentStrategy
    def score_for(letter,dictionary)
      dictionary.length - dictionary.words_that_contain(letter)
    end
  end

  # Guess the letter that appears in approx half of the words
  # If there's only one word left, use the letters in that word first
  class MidpointStrategy
    def score_for(letter,dictionary)
      if dictionary.length >= 2 then
        midpoint = dictionary.length / 2
        nbwords = dictionary.words_that_contain(letter)
        midpoint > nbwords ? midpoint - nbwords : nbwords - midpoint
      else
        dictionary.length - dictionary.words_that_contain(letter)
      end
    end
  end

  # Guess the letter that appears in approx 3/4 of the words
  class ThreeQuaterpointStrategy
    def score_for(letter,dictionary)
      if dictionary.length >= 2 then
        midpoint = 3 * dictionary.length / 4
        nbwords = dictionary.words_that_contain(letter)
        midpoint > nbwords ? midpoint - nbwords : nbwords - midpoint
      else
        dictionary.length - dictionary.words_that_contain(letter)
      end
    end
  end

  # Guess the letter that appears in most words, using the frequency of letters in English words
  # Doesn't take the dictionary into account
  class EnglishFrequencyStrategy
    def score_for(letter,dictionary)
      frequencies = "earitnoslcumdphbgyfvkwxqjz"
      frequencies.index(letter)
    end
  end

  # The HangMan solving class
  # Play is simple:
  #  - Give the solver a puzzle to solve as a string of '-', a dictionary and optionally a stratagy for choosing the next letter
  #  - Ask the solver for a guess
  #  - Tell the solver it took a wrong guess: the letter doesn't appear in the solution
  #  - Or tell the solver it took a good guess. Give it a string with '-' replaced with the good letter
  #  - Keep on going until the puzzle is solved
  class HangManSolver
    # The current solution
    attr_reader :solution

    # Create a HangMan Solver
    #  puzzle should be a string of '-' as long as the word to guess
    #  dictionary is a Dictionary. The solver can find words that are not in the dictionary
    #  strategy is an optional parameter to determine the letter choosing strategy
    #   a Strategy object should implement one method score_for(letter,dictionary) => numeric score
    #   the lowest scoring letter is chosen
    def initialize(puzzle,dictionary,strategy=MostFrequentStrategy.new)
      @solution = puzzle.dup
      @dictionary = dictionary.with_only_words_of_size(puzzle.length)
      @possible_letters = ('a'..'z').to_a
      @strategy = strategy
    end

    def merge(answer)
      for pos in 0..@solution.length
        if @solution[pos] == ?- && answer[pos] != ?- then
          @solution[pos] = answer[pos]
        end
      end
      @solution
    end

    # Returns true if the solution is known
    def solved?
      @solution !~ /-/
    end

    # How many more Words in the dictionary are candidates?
    def possibilities
      @dictionary.length
    end

    # Returns the letter that the solver guesses
    # Uses the strategy to determine the letter with the lowest score
    def guess
      letters = @possible_letters.collect {|letter| [ score_for(letter),letter ]}
      letter = letters.min {|letter1,letter2| letter1 <=> letter2 }
      letter[1]
    end

    # Tell the solver that the letter does not appear in the solution
    def wrong_guess(letter)
      @possible_letters.delete(letter)
      @dictionary.reject_words_that_contain(letter)
    end

    # Tell the solver that the letter was a good guess, by placing the letter in the solution
    # e.g. to indicate that 'a' is a good guess for 'hangman' pass '-a---a-'
    def good_guess(pattern)
      merge(pattern)
      @dictionary.keep_only_words_that_match(@solution)
      @possible_letters.delete(letter_in(pattern))
    end

    private
    def score_for(letter)
      @strategy.score_for(letter,@dictionary)
    end

    def letter_in(pattern)
      result = ' '
      pattern.each_byte {|char| result[0] = char if char != ?-}
      result
    end
  end

  # The HangManPlayer can tell if the Solver made a good/wrong guess
  class HangManPlayer
    def initialize(word)
      @solution = word.dup
    end

    def evaluate(letter)
      template = ''
      @solution.each_byte do |char| 
        template << (char == letter[0] ? char : ?-) 
      end
      template
    end
  end

  # The Game uses the Solver and Player to find a word, given a dictionary and a strategy
  class HangManGame

    # Finds the given word, using the dictionary and the strategy
    # Returns:
    #  the word found
    #  the number of wrong guesses
    #  an array of guesses. Each item is a '+' (good guess) or '-' (wrong guess) and the letter guessed
    def self.solve(word,dictionary,strategy=MostFrequentStrategy.new)
      guesses = []
      empty = '-' * word.length
      player = HangManPlayer.new(word)
      puzzle = HangManSolver.new(empty ,dictionary,strategy)
      wrong_guesses = 0
      while !puzzle.solved? do
        letter = puzzle.guess
        pattern = player.evaluate(letter)
        if pattern == empty then
          puzzle.wrong_guess(letter)
          wrong_guesses += 1
          guesses << "-#{letter}"
        else
          puzzle.good_guess(pattern)
          guesses << "+#{letter}"
        end
      end

      return puzzle.solution,wrong_guesses,guesses
    end
  end

  describe Word do
    it "should identify its unique letters" do
      word = Word.new('banana')
      word.letters.length.should eql(3)
      word.letters.should include(?b)
      word.letters.should include(?a)
      word.letters.should include(?n)
    end
  end

  describe Dictionary do
    it "should contain words" do
      dict = Dictionary.new

      dict.add("hangman")
      dict.add("packman")
      dict.add("rackham")

      dict.length.should == 3
    end

    it "should select only words of a certain size" do
      dict = Dictionary.new

      dict.add("hangman")
      dict.add("packman")
      dict.add("rackham")
      dict.add("rat")
      dict.add("hang")

      dict.keep_only_words_of_length(7)
      dict.length.should ==(3)
    end

    it "should load word files" do
      dict = Dictionary.new
      dict.load("words.txt")
      dict.length.should eql(20905)
      dict.keep_only_words_of_length(7)
      dict.length.should eql(3872)
    end

    it "should select words that match pattern" do
      dict = Dictionary.new
      dict.load("words.txt")
      dict.length.should eql(20905)
      dict.keep_only_words_that_match('h------')
      dict.length.should eql(155)
      dict.keep_only_words_that_match('ha---a-')
      dict.length.should eql(11)
    end

    it "should throw away words that contain a wrong letter" do
      dict = Dictionary.new
      dict.load("words.txt")
      dict.length.should eql(20905)
      dict.reject_words_that_contain('z')
      dict.length.should eql(20605)
      dict.reject_words_that_contain('x')
      dict.length.should == 20075
    end

    it "should know how many words contain a certain letter" do
      dict = Dictionary.new
      dict.load("words.txt")
      dict.length.should eql(20905)

      dict.words_that_contain('e').should eql(13211)
      dict.words_that_contain('f').should eql(1915)
      dict.words_that_contain('z').should eql(300)
      dict.words_that_contain('r').should eql(10403)
    end
  end

  describe HangManPlayer do

    it "should evaluate guesses" do
      player = HangManPlayer.new("hangman")

      player.evaluate('a').should eql('-a---a-')
      player.evaluate('b').should eql('-------')
      player.evaluate('m').should eql('----m--')
    end


  end

  describe HangManSolver do
    it "should accept a puzzle" do
      puzzle = HangManSolver.new("-------",Dictionary.new)
    end

    it "should merge solutions and answers" do
      puzzle = HangManSolver.new("-------",Dictionary.new)
      puzzle.solution.should eql("-------")
      puzzle.merge("-a---a-")
      puzzle.solution.should eql("-a---a-")
      puzzle.merge("----m--")
      puzzle.solution.should eql("-a--ma-")
    end

    it "should know when it's solved" do
      puzzle = HangManSolver.new("-------",Dictionary.new)
      puzzle.solved?.should be_false

      puzzle.merge('h------')
      puzzle.solved?.should be_false

      puzzle.merge('-angman')
      puzzle.solved?.should be_true
    end

    it "should find 'hangman'" do
      puzzle = HangManSolver.new("-------",Dictionary.new.load("words.txt"))
      puzzle.possibilities.should eql(3872)
      puzzle.guess.should eql('e')
      puzzle.wrong_guess('e')      
      puzzle.possibilities.should eql(1490)
      puzzle.guess.should eql('a')
      puzzle.good_guess('-a---a-')
      puzzle.possibilities.should eql(69)
      puzzle.guess.should eql('r')
      puzzle.wrong_guess('r')      
      puzzle.possibilities.should eql(37)
      puzzle.guess.should eql('n')
      puzzle.good_guess('--n---n')
      puzzle.possibilities.should eql(2)
      puzzle.guess.should eql('m')
      puzzle.good_guess('----m--')
      puzzle.possibilities.should eql(2)
      puzzle.guess.should eql('d')
      puzzle.wrong_guess('d')      
      puzzle.possibilities.should eql(1)
      puzzle.guess.should eql('g')
      puzzle.good_guess('---g---')
      puzzle.possibilities.should eql(1)
      puzzle.guess.should eql('h')
      puzzle.good_guess('h------')
      puzzle.possibilities.should eql(1)
      puzzle.solution.should eql('hangman')
    end
  end

  describe HangManGame do

    it "should find words in the dictionary" do
      dictionary = Dictionary.new
      dictionary.load("words.txt")
      solution, round = HangManGame.solve('hockey',dictionary)

      solution.should eql('hockey')
    end

    it "should find words not in the dictionary" do
      dictionary = Dictionary.new
      dictionary.add('hockey')      
      dictionary.add('cyclic')      
      solution, round = HangManGame.solve('pascal',dictionary)

      solution.should eql('pascal')
    end

    it "should find all words in the dictionary" do
      # result[i] contains the number of words that made i wrong guesses
      result = Array.new(26,0)

      dictionary = Dictionary.new
      dictionary.load("words.txt")

      # Change the strategy to test another type of strategy
      strategy = MostFrequentStrategy.new
      dictionary.each do |word|
        solution,wrong_guesses,guesses = HangManGame.solve(word.word,dictionary,strategy)
        solution.should eql(word.word)
        result[wrong_guesses] += 1
      end
      # Uncomment to print out the number of words per number of wrong guesses
      # puts "=> #{result.inspect}"
    end

  end
end
