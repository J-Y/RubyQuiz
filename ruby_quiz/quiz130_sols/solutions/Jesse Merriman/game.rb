require 'phrase'

module Hangman
  class Game
    def initialize interface, ai
      @interface, @ai = interface, ai
      self
    end

    def run
      @phrase = @interface.phrase_pattern
      @interface.display @phrase, @ai.lives, @ai.max_lives

      while not done?
        guess
        @interface.display @phrase, @ai.lives, @ai.max_lives
      end

      finish
    end

    private

    def guess
      letter = @ai.guess @phrase
      pos = @interface.suggest letter

      if pos.empty?
        @ai.lose_life
      else
        pos.each { |pos| @phrase[pos] = letter }
      end
    end
 
    def done?
      @ai.dead? or (not @phrase.include?(Phrase::BlankChar))
    end

    def finish
      @interface.finish @ai.dead?
    end
  end
end
