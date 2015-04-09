#!/usr/bin/env ruby

ALLOWED_WRONG_GUESSES = 6

WORD_LIST_FILENAME = '/usr/share/dict/words'

WORD_LIST = {}

File.open(WORD_LIST_FILENAME) do |f|
  f.each { |word|  WORD_LIST[word.strip.downcase] = true }
end

FREQUENCY_ORDER = %w{etaoin shrdlu cmfwyp vbgkqj xz}.collect { |elem| elem.split('') }.flatten

GUESSES_MADE = {}

puts 'Enter a word pattern'
old_pattern = pattern = gets.chomp

loop do
  if pattern.match(/^[a-zA-Z\-]+$/)
    if pattern.match(/-/)
      if GUESSES_MADE.values.select { |val|  val == false }.length > ALLOWED_WRONG_GUESSES
        puts 'crap I lost'
        exit
      end

      regex = Regexp.new("^#{pattern.downcase.gsub(/-/, '.')}$")
      possible_words = WORD_LIST.keys.select { |word| word.match(regex) }
      possible_letters = possible_words.collect { |word| word.split('') }.flatten.uniq
      guess = ((FREQUENCY_ORDER - GUESSES_MADE.keys) & possible_letters).first
      puts guess.upcase
      pattern = gets.chomp

      GUESSES_MADE[guess] = (pattern != old_pattern)
      puts "wrong guesses made: #{GUESSES_MADE.values.select { |val| val == false }.length}"
      old_pattern = pattern
    else
      puts 'Yay I won'
      exit
    end
  else
    puts 'This pattern makes no sense.'
    exit
  end
end
