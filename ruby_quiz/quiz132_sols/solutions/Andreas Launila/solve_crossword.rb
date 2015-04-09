require 'enumerator'
require 'rubygems'
require 'gecoder'

# The base we use when converting words to and from numbers.
BASE = ('a'..'z').to_a.size
# The offset of characters compared to digits in word-numbers.
OFFSET = 'a'[0]
# The range of integers that we allow converted words to be in. We are
# only using the unsigned half, we could use both halves, but it would complicate
# things without giving a larger allowed word length.
ALLOWED_INT_RANGE = 0..Gecode::Raw::Limits::Int::INT_MAX
# The maximum length of a word allowed.
MAX_WORD_LENGTH = (Math.log(ALLOWED_INT_RANGE.last) /
  Math.log(BASE)).floor

# Describes an immutable dictionary which represents all contained words
# as numbers of base BASE where each digit is the corresponding letter
# itself converted to a number of base BASE.
class Dictionary
  # Creates a dictionary from the contents of the specified dictionary
  # file which is assumed to contain one word per line and be sorted.
  def initialize(dictionary_location)
    @word_arrays = []
    File.open(dictionary_location) do |dict|
      previous_word = nil
      dict.each_line do |line|
        word = line.chomp.downcase
        # Only allow words that only contain the characters a-z and are
        # short enough.
        next if previous_word == word or word.size > MAX_WORD_LENGTH or
          word =~ /[^a-z]/
        (@word_arrays[word.length] ||= []) << self.class.s_to_i(word)
        previous_word = word
      end
    end
  end

  # Gets an enumeration containing all numbers representing word of the
  # specified length.
  def words_of_size(n)
    @word_arrays[n] || []
  end

  # Converts a string to a number of base BASE (inverse of #i_to_s ).
  def self.s_to_i(string)
    string.downcase.unpack('C*').map{ |x| x - OFFSET }.to_number(BASE)
  end

  # Converts a number of base BASE back to the corresponding string
  # (inverse of #s_to_i ).
  def self.i_to_s(int)
    res = []
    loop do
      digit = int % BASE
      res << digit
      int /= BASE
      break if int.zero?
    end
    res.reverse.map{ |x| x + OFFSET }.pack('C*')
  end
end

class Array
  # Computes a number of the specified base using the array's elements
  # as digits.
  def to_number(base = 10)
    inject{ |result, variable| variable + result * base }
  end
end

# Models the solution to a partially completed crossword.
class Crossword < Gecode::Model
  # The template should take the format described in RubyQuiz #132 . The
  # words used are selected from the specified dictionary.
  def initialize(template, dictionary)
    @dictionary = dictionary

    # Break down the template and create a corresponding square  matrix.
    # We let each square be represented by integer variable with domain
    # -1...BASE where -1 signifies # and the rest signify letters.
    squares = template.split(/\n\s*\n/).map!{ |line| line.split(' ') }
    @letters = int_var_matrix(squares.size, squares.first.size,
      -1...BASE)

    # Do an initial pass, filling in the prefilled squares.
    squares.each_with_index do |row, i|
      row.each_with_index do |letter, j|
        unless letter == '_'
          # Prefilled letter.
          @letters[i,j].must == self.class.s_to_i(letter)
        end
      end
    end

    # Add the constraint that sequences longer than one letter must form
    # words. @words will accumelate all word variables created.
    @words = []
    # Left to right pass.
    left_to_right_pass(squares, @letters)
    # Top to bottom pass.
    left_to_right_pass(squares.transpose, @letters.transpose)

    branch_on wrap_enum(@words), :variable => :largest_degree,
      :value => :min
  end

  # Displays the solved crossword in the same format as shown in the
  # quiz examples.
  def to_s
    output = []
    @letters.values.each_slice(@letters.column_size) do |row|
      output << row.map{ |x| self.class.i_to_s(x) }.join(' ')
    end
    output.join("\n\n").upcase.gsub('#', ' ')
  end

  private

  # Parses the template from left to right, line for line, constraining
  # sequences of two or more subsequent squares to form a word in the
  # dictionary.
  def left_to_right_pass(template, variables)
    template.each_with_index do |row, i|
      letters = []
      row.each_with_index do |letter, j|
        if letter == '#'
          must_form_word(letters) if letters.size > 1
          letters = []
        else
          letters << variables[i,j]
        end
      end
      must_form_word(letters) if letters.size > 1
    end
  end

  # Converts a word from integer form to string form, including the #.
  def self.i_to_s(int)
    if int == -1
      return '#'
    else
      Dictionary.i_to_s(int)
    end
  end

  # Converts a word from string form to integer form, including the #.
  def self.s_to_i(string)
    if string == '#'
      return -1
    else
      Dictionary.s_to_i(string)
    end
  end

  # Constrains the specified variables to form a word contained in the
  # dictionary.
  def must_form_word(letter_vars)
    raise 'The word is too long.' if letter_vars.size > MAX_WORD_LENGTH
    # Create a variable for the word with the dictionary's words as
    # domain and add the constraint.
    word = int_var @dictionary.words_of_size(letter_vars.size)
    letter_vars.to_number(BASE).must == word
    @words << word
  end
end

puts 'Reading the dictionary...'
dictionary = Dictionary.new(ARGV.shift || '/usr/share/dict/words')
puts 'Please enter the template (end with ^D)'
template = ''
loop do
  line = $stdin.gets
  break if line.nil?
  template << line
end
puts 'Building the model...'
model = Crossword.new(template, dictionary)
puts 'Searching for a solution...'
puts((model.solve! || 'Failed').to_s)
