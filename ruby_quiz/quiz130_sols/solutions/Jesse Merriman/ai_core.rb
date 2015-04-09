module Hangman
  module AI
    def AI.looks_ok? possible_ai
      possible_ai.respond_to? :guess
    end

    class Core
      DefaultMaxLives = 6
      DefaultLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      attr_reader :lives, :max_lives, :letter_pool

      def initialize(lives = DefaultMaxLives, letters = DefaultLetters)
        @lives = lives.to_i
        @max_lives = lives.to_i
        @letter_pool = letters.split(//)
      end

      def lose_life; @lives = [0, @lives-1].max; end

      def dead?; @lives.zero?; end

      private

      def random_letter
        @letter_pool[rand(@letter_pool.size)]
      end
    end
  end
end
