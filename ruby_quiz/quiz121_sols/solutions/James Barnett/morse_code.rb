#!/usr/bin/env ruby

class MorseCode
  attr_accessor :results
  attr_reader :words

  Alphabet = {
    'A' => '.-', 'B' => '-...', 'C' => '-.-.', 'D' => '-..',
    'E' => '.', 'F' => '..-.', 'G' => '--.', 'H' => '....', 'I' => '..',
    'J' => '.---', 'K' => '-.-', 'L' => '.-..', 'M' => '--', 'N' => '-.',
    'O' => '---', 'P' => '.--.', 'Q' => '--.-', 'R' => '.-.', 'S' => '...',
    'T' => '-', 'U' => '..-', 'V' => '...-', 'W' => '.--', 'X' => '-..-',
    'Y' => '-.--', 'Z' => '--..'
  }

  def initialize
    @results = []
    @words = []
    @words << load_dictionary
  end

  def to_text(input, output = "", words = @words)
    unless input.empty?
      m = matches(input)
      m.each do |char|
        to_text(input[Alphabet[char].length, input.length], output +
char)
      end
    else
      @results << output
    end
  end

  def matches(input)
    Alphabet.select { |key, value| input[0, value.length] ==
value }.map { |v| v.first }.sort
  end

  def load_dictionary
    # dictionary.txt from http://java.sun.com/docs/books/tutorial/collections/interfaces/examples/dictionary.txt
    File.open("dictionary.txt", "r") do |file|
      file.each_line do |line|
        @words << line.chomp.upcase if line
      end
    end
    @words << 'SOFIA'
    @words << 'EUGENIA'
  end

  def in_dictionary?(str)
    @words.include?(str)
  end
end

$mc = MorseCode.new
$mc.to_text(ARGV[0])
$mc.results.each { |r| puts "#{r} #{ $mc.in_dictionary?(r) ? "(in
dictionary)" : "" }" }
