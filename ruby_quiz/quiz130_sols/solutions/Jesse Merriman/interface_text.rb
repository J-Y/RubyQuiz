require 'interface_core'

module Hangman
  module Interface
    class Text < Core
      def phrase_pattern
        print 'Enter a phrase pattern: '
        $stdout.flush
        $stdin.gets.chomp
      end

      def suggest letter
        print "I guess #{letter}. What position(s) is it in? "
        $stdout.flush
        $stdin.gets.chomp.split(' ').map { |x| x.to_i - 1}
      end

      def display phrase, lives, max_lives
        puts "#{phrase}  |  Computer lives: #{lives}"
      end

      def finish user_won
        puts
        if user_won
          puts "I'm out of lives, so you won! Congrats."
        else
          puts "Woot! I win!"
        end
      end
    end
  end
end
