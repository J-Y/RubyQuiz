# Cows and Bulls game classes
#
# (c) 2005 Brian Schröder
# http://ruby.brian-schroeder.de/quiz/cows-and-bulls/
#
# This code is published under the GPL. 
# See http://www.gnu.org/copyleft/gpl.html for more information.

class Array
  def random_pick
    self[rand(self.length)]
  end
end

# Cows and bulls game class. See also the CowsAndBullsNetworkGame class that is connected to this class via a simple network protocoll
class CowsAndBullsGame
  private 
  # Returns the number of cows that +guess+ has relative to the previously picked word (see #pick_word).
  # Cows are correct letters at the wrong position. I calculate here: | correct_letters | - | bulls |
  def cows(guess)
    letters = @word.split(//)
    guess.split(//).inject(0) { | r, letter | letters.delete(letter) ? r + 1 : r } - bulls(guess)
  end

  # Returns the number of bulls that +guess+ has relative to the previously picked word (see #pick_word).
  # Bulls are correct e
  def bulls(guess)
    guess.split(//).zip(@word.split(//)).inject(0) { | r, (letter_1, letter_2) | letter_1 == letter_2 ? r + 1 : r }
  end 
  
  public
  def initialize(word)
    @word = word
    @correct = false
  end
  
  # Make a guess
  def guess=(guess)
    @cows = cows(guess) rescue 0
    @bulls = bulls(guess) rescue 0
    @correct = guess == @word
  end

  # Return the length of the picked word
  def word_length
    @word.length
  end

  # Return number of cows and bulls in current guess
  def cows_and_bulls
    [@cows, @bulls]
  end
  
  # True iff current guess is correct
  def correct
    @correct
  end
end

