require 'ai_core'

module Hangman
  module AI
    class Random < Core
      def initialize lives = DefaultMaxLives, letters = DefaultLetters
        super(lives, letters)
      end

      def guess phrase
        @letter_pool.delete random_letter
      end
    end
  end
end
