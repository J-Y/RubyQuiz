#!/usr/bin/env ruby -wKU

puts "One moment..."
puts
require "words"

def frequency(words)
  freq = Hash.new(0)
  words.each do |word|
    word.split("").each { |letter| freq[letter] += word.count(letter) }
  end
  freq
end
FREQ = frequency(WORDS).sort_by { |_, count| -count }.map { |letter, _| letter }

choices = WORDS
guesses = Array.new

loop do
  puts guesses.empty?                                       ?
       "Please enter a word pattern (_ _ _ _ for example):" :
       "Please update your pattern according to my guess (_ i _ _ for example):"
  $stdout.flush
  pattern = $stdin.gets.to_s.delete("^A-Za-z_")

  bad_guesses = guesses - pattern.delete("_").split("")
  if bad_guesses.size > 5 and pattern.include? "_"
    puts "I'm out of guesses.  You win."
  elsif not pattern.include? "_"
    puts "I guessed your word.  Pretty smart, huh?"
  else
    choices = choices.grep(
                bad_guesses.empty?             ?
                /\A#{pattern.tr("_", ".")}\Z/i :
                /\A(?!.*[#{bad_guesses.join}])#{pattern.tr("_", ".")}\Z/i
              )
    guess = frequency(choices).
              reject { |letter, _| guesses.include? letter }.
              sort_by { |letter, count| [-count, FREQ.index(letter)] }.
              first.first rescue nil

    guesses << guess
    puts "I guess the letter '#{guess}'."
    puts
    next
  end

  puts
  if ARGV.include? "--loop"
    choices = WORDS
    guesses = Array.new
  else
    break
  end
end
