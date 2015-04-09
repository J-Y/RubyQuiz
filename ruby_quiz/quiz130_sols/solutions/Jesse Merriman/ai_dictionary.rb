require 'ai_core'
require 'phrase'

module Hangman
  module AI
    class Dictionary < Core
      def initialize lives = DefaultMaxLives, letters = DefaultLetters,
                     dict_file = 'dict.txt'
        super(lives, letters)
        raise "#{dict_file} does not exist!" if not File.exists? dict_file
        @dict_file = dict_file
      end

      def guess phrase
        reg = Phrase.regexp phrase
        file = File.new @dict_file
        possible = file.grep(reg).map { |x| x.chomp.upcase }
        file.close
        letter = choose_letter possible, phrase
        @letter_pool.delete letter
      end

      private

      # Choose a letter to try to fill in the blanks in phrase. words is an
      # Enumerable of possible words. Letters that occur frequently in them
      # will be preferred.
      def choose_letter words, phrase
        # First, build up a hash of the counts of all letters in the blank
        # locations of the words.
        blank_indices = Phrase.blank_indices phrase
        letter_to_count = Hash.new { |h, k| h[k] = 0 }

        words.each do |word|
          blank_indices.each do |i|
            letter_to_count[word[i..i]] += 1
          end
        end

        # Removed previously-chosen letters.
        letter_to_count.delete_if { |k, v| not @letter_pool.include? k }

        # Find a maximum based on the values (which are the counts).
        best = letter_to_count.max { |x, y| x.last <=> y.last }

        # If there is a maximum, use it, else fall back on a random pick.
        best.nil? ? random_letter : best.first.upcase
      end
    end
  end
end
