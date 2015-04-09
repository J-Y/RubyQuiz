# file: morse_trained.rb
# author: Drew Olson

# the train method is based on this rubytalk post:
# http://www.ruby-forum.com/topic/104327#new
#
# we build a model based on the frequency of words
# within the text provided here: http://www.norvig.com/holmes.txt combined
# with the frequency in the local dictionary. this means any word in the dictionary
# will have a frequency of 1 and words appearing in the holmes text will have
# increased frequencies, thus being favored in the sort later in the program.
# the goal is the present the user with the most relevant matches first.
# both files were saved locally.
def train texts
  model = Hash.new(0)
  texts.each do |text|
    File.new(text).read.downcase.scan(/[a-z]+/).each do |word|
      model[word] += 1
    end
  end
  return model
end

# global hash of word -> frequency pairs
NWORDS = train ['holmes.txt','dictionaries/2of4brif.txt']

# MorseLetter holds a pattern and the letter associated
# with the pattern
MorseLetter = Struct.new(:pattern,:letter)

# global array to hold all the MorseLetter objects
LETTERS = [MorseLetter.new(/^\.-/,"A"),
MorseLetter.new(/^-\.\.\./,"B"),
MorseLetter.new(/^-\.-\./,"C"),
MorseLetter.new(/^-\.\./,"D"),
MorseLetter.new(/^\./,"E"),
MorseLetter.new(/^\.\.-\./,"F"),
MorseLetter.new(/^--\./,"G"),
MorseLetter.new(/^\.\.\.\./,"H"),
MorseLetter.new(/^\.\./,"I"),
MorseLetter.new(/^\.---/,"J"),
MorseLetter.new(/^-\.-/,"K"),
MorseLetter.new(/^\.-\.\./,"L"),
MorseLetter.new(/^--/,"M"),
MorseLetter.new(/^-\./,"N"),
MorseLetter.new(/^---/,"O"),
MorseLetter.new(/^\.--\./,"P"),
MorseLetter.new(/^--\.-/,"Q"),
MorseLetter.new(/^\.-\./,"R"),
MorseLetter.new(/^\.\.\./,"S"),
MorseLetter.new(/^-/,"T"),
MorseLetter.new(/^\.\.-/,"U"),
MorseLetter.new(/^\.\.\.-/,"V"),
MorseLetter.new(/^\.--/,"W"),
MorseLetter.new(/^-\.\.-/,"X"),
MorseLetter.new(/^-\.--/,"Y"),
MorseLetter.new(/^--\.\./,"Z")]

# a recursive method which checks the code for letter matches,
# builds the translation string, removes the matched
# portion of the code and then recurses
#
# the method returns an array of all possible morse code translations
def translate code, translation = ""

  # recursion base case:
  #
  # return an array containing the translation if the code has
  # a size of 0
  return [translation.downcase] if code.size.zero?

  words = []

  # check all possible matches to the code
  LETTERS.each do |letter|
    if code[letter.pattern]

      # recurse on untranslated portion of the code
      # and new translation
      # add results to our array at this level of recursion
      words += translate code.sub(letter.pattern,''),translation+letter.letter
    end
  end

  return words

end

# read the initial code from standard input
code = gets.chomp

# initial call to translate with the complete code
# and no translation string
words = translate code

# sort the resulting words first based on the frequency in NWORDS
# and the dictionary in a decreasing order and then by the word itself. this
# preserves alphabetical order when words have the same frequency or
# do not appear in the dictionary. we then print each word along with an
# asterisk if that word is in the dictionary (or in the training material
# but not in the dictionary).
words.sort_by{|word| [-NWORDS[word],word] }.each do |word|
  puts "#{word.capitalize} #{"*" if NWORDS[word] > 0}"
end
