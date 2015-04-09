#!/usr/bin/env ruby

# morse_code.rb
# Ruby Quiz 121: Morse Code

require 'set'

Decode = {
  '.-'   => 'A', '-...' => 'B', '-.-.' => 'C', '-..'  => 'D', '.'    => 'E',
  '..-.' => 'F', '--.'  => 'G', '....' => 'H', '..'   => 'I', '.---' => 'J',
  '-.-'  => 'K', '.-..' => 'L', '--'   => 'M', '-.'   => 'N', '---'  => 'O',
  '.--.' => 'P', '--.-' => 'Q', '.-.'  => 'R', '...'  => 'S', '-'    => 'T',
  '..-'  => 'U', '...-' => 'V', '.--'  => 'W', '-..-' => 'X', '-.--' => 'Y',
  '--..' => 'Z'
}

# Could hard-code these, but what fun would that be?
MinCodeLength = Decode.keys.min { |k,j| k.length <=> j.length }.length
MaxCodeLength = Decode.keys.max { |k,j| k.length <=> j.length }.length

class Array
  # Yield once for each way of grouping the elements into groups of size
  # between min_length and max_length (inclusive). It works recursively:
  # empty arrays return self, and longer arrays take all initial (head)
  # slices of valid lengths, and append to that each grouping of the
  # remaining tail.
  def each_grouping(min_length, max_length)
    if empty?
      yield self
    else
      max_length = size if size < max_length
      (min_length..max_length).each do |code_length|
        head = [slice(0, code_length)]
        slice(code_length..-1).each_grouping(min_length, max_length) do |tail|
          yield head + tail
        end
      end
    end
  end
end

class String
  # Yield once for each translation of this (Morse code) string.
  def each_translation
    split(//).each_grouping(MinCodeLength, MaxCodeLength) do |group|
      valid = true
      group.map! do |char_arr|
        # Convert arrays of individual dots & dashes to strings, then translate.
        letter = Decode[char_arr.join]
        letter.nil? ? (valid = false; break) : letter
      end
      # Join all the translated letters into one string.
      yield group.join if valid
    end
  end
end

if $0 == __FILE__
  src = $stdin
  dict = Set[]

  if ARGV.include?('--matching')
    trans_handler = lambda do |trans|
      puts trans if dict.include? trans
    end
  else
    trans_handler = lambda do |trans|
      print trans
      dict.include?(trans) ? puts(' <-- In dictionary!') : puts
    end
  end

  puts 'Enter morse code to translate:'
  code = src.gets.chomp
  puts 'Enter dictionary words (case does not matter, EOF when done):'
  while dict_word = src.gets
    dict << dict_word.chomp.upcase
  end

  puts 'Translations:'
  code.each_translation { |trans| trans_handler[trans] }
end
