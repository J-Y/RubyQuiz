#!/usr/bin/env ruby -wKU

require "words"

results = Hash.new(0)
at_exit do
  results[:total] = results[:right] + results[:wrong]
  puts
  puts   "Words:     #{results[:total]}"
  puts   "Guessed:   #{results[:right]}"
  puts   "Missed:    #{results[:wrong]}"
  printf "Accuracy:  %.2f%%\n", results[:right] / results[:total].to_f * 100
  puts
end
trap("INT") { exit }

IO.popen( File.join(File.dirname(__FILE__), "hangman.rb --loop"),
          "r+" ) do |hangman|
  WORDS.each do |word|
    pattern = word.tr("a-z", "_")
    loop do
      input = String.new
      hangman.each do |line|
        input << line
        break if input =~ /^(?:I'm out|I guessed)|:\Z/
      end

      if input =~ /^I'm out/
        puts "It missed '#{word}'."
        results[:wrong] += 1
        break
      elsif input =~ /^I guessed/
        puts "It guessed '#{word}'."
        results[:right] += 1
        break
      elsif input =~ /^I guess the letter '(.)'/
        guess = $1
        word.split("").each_with_index do |letter, i|
          pattern[i, 1] = letter if letter == guess
        end
      end

      hangman.puts pattern
    end
  end
end
