#!/usr/bin/env ruby
#
#  Author: Dan Manges - http://www.dcmanges.com
#  Ruby Quiz #108 - http://rubyquiz.com/quiz108.html

class WordList
  include Enumerable

  attr_accessor :file
  attr_reader   :filters

  def initialize(file = nil)
    @file, @filters = file, []
  end

  def each
    File.open(@file, "r") do |file|
      while line = file.gets
       yield apply_filters(line.chomp)
      end
    end
  end

  protected

  def apply_filters(word)
    @filters.inject(word) do |word, filter|
      filter.call(word)
    end
  end

end

# Module to select words based on length and letter composition.
module WordFinder
  # Finds words of length +size+ which can be composed with the letters  in +base_word+
  def find_words(size, base_word)
    letter_counts = base_word.split(//).inject(Hash.new(0)) { |hash,letter| hash[letter] += 1; hash }
    regexp = Regexp.new("^" + letter_counts.map { |letter,count|  "#{letter}{0,#{count}}"}.sort.join + "$")
    select { |word| word.to_s.size == size && word.split(//).sort.join  =~ regexp }
  end

  # Finds a random word of the given size
  def random_word_of_size(size)
    words = find_words(size, (('a'..'z').to_a * 3).join)
    words[rand(words.size)]
  end
end

WordList.send(:include, WordFinder)

# Dictionary file from: http://wordlist.sourceforge.net/
# http://prdownloads.sourceforge.net/wordlist/alt12dicts-4.tar.gz
@wordlist = WordList.new("/Users/dan/Desktop/alt12dicts/2of12full.txt")
# This particular wordlist has an offset
@wordlist.filters << lambda { |word| word[17..-1] }
# Skip proper names, contractions, etc.
@wordlist.filters << lambda { |word| word =~ /^[a-z]+$/ ? word : "" }

module WordBlender
  class Round
    def initialize(wordlist, word_size = (3..6))
      @wordlist = wordlist
      @min_size, @max_size = word_size.first, word_size.last
      @qualified = false
      @hits = Hash.new { |h,k| h[k] = [] }
      load_words
    end

    def qualified?
      @qualified
    end

    def guess?(word)
      word = word.to_s.strip
      dup?(word) || qualify?(word) || hit?(word) || :miss
    end

    def letters
      @base.split(//).sort
    end

    def status
      result = []
      @min_size.upto(@max_size) do |size|
        result << [size, @hits[size].size, @words[size].size]
      end
      result.map { |data| "#{data[0]} letters: #{data[1]} of #{data[2]}"}.join(", ")
    end

    protected

    def dup?(word)
      :dup if @hits[word.size].include?(word)
    end

    def qualify?(word)
      if @words[word.size].include?(word) and word.size == @max_size
        @hits[word.size] << word
        @qualified = true
        :qualify
      end
    end

    def hit?(word)
      if @words[word.size].include?(word)
        @hits[word.size] << word
        :hit
      end
    end

    def load_base_word
      @base = @wordlist.random_word_of_size(@max_size)
    end

    def load_words
      @words = Hash.new([])
      load_base_word
      @min_size.upto(@max_size) do |size|
        @words[size] = @wordlist.find_words(size, @base)
      end
    end
  end

  class Game
    def initialize(wordlist)
      @wordlist = wordlist
      reset
    end

    def start!
      help
      start_round
      print 'guess> '
      while input = gets
        input = input.strip
        break if input == ".quit"
        if input[0,1] == "." && respond_to?(input[1..-1])
          send(input[1..-1])
          print 'guess> '
          next
        end
        result = @round.guess?(input)
        puts case result
          when :miss
            "Wrong!"
          when :dup
            "Already guessed that!"
          when :hit
            "You got it!"
          when :qualify
            "You got it! And you qualify for the next round!"
        end + " " + input
        status unless result == :miss
        print 'guess> '
      end
      puts "Goodbye!"
    end
    alias :play! :start!

    protected

    def letters
      puts "Available Letters: " + @round.letters.sort_by {rand}.join(', ')
    end

    def next
      if @round.qualified?
        start_round
      else
        puts "You have not yet qualified for the next round!"
      end
    end

    def help
      puts <<-END_HELP
      When prompted, either enter a word or a command.
      The following commands are available:
        .quit => quits the game
        .help => display this help
        .next => goes to the next round (if qualified)
        .letters => display available letters
        .status  => show the current status of this round
      END_HELP
    end

    def reset
      @round_number = 0
    end

    def start_round
      @round_number += 1
      @round = Round.new(@wordlist)
      puts "Beginning Round #{@round_number}!"
      letters
    end

    def status
      puts @round.status
    end
  end
end

@blender = WordBlender::Game.new(@wordlist)
@blender.play!
