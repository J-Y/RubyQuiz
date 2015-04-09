#  [RubyQuiz:121 - MorseCode]
#
#  Recursive solution with a little bit of caching...

require 'memoize'
include Memoize

ENCODINGS = {
  'A' => '.-',  'B' => '-...',  'C' => '-.-.',  'D' => '-..',  'E' => '.',
  'F' => '..-.',  'G' => '--.',  'H' => '....',  'I' => '..',  'J' => '.---',
  'K' => '-.-',  'L' => '.-..',  'M' => '--',  'N' => '-.',  'O' => '---',
  'P' => '.--.',  'Q' => '--.-',  'R' => '.-.',  'S' => '...',  'T' => '-',
  'U' => '..-',  'V' => '...-',  'W' => '.--',  'X' => '-..-',  'Y' => '-.--',
  'Z' => '--..'
}

class String
  def starts_with? s
    return self[0...s.length] == s
  end 
end

def next_steps(code)
  #-- Find eligible steps, return the decoded character and the remaining morse
  ENCODINGS.select { |alpha_char, morse_char| code.starts_with?(morse_char) }.map do | (alpha_char, morse_char) |
    [alpha_char, code.sub(morse_char, "")]
  end
end

def decodings(code) 
  retval = []

  #-- Base: nothing to decode -> return empty string
  if (code == "")
    retval << ""
  else
    #-- Step: Process each possible char-tail tuple, recurse on the tail to construct all possible words...
    next_steps(code).each do |head, tail|   
      decodings(tail).each do |plaintext|
        retval << (head + plaintext)
      end   
    end   
  end
  retval
end

memoize(:next_steps, 'ns.dat') #-- Performance boost when repeatedly checking the same tails.
puts "Please enter some morse code... "
input=gets.chomp
decodings(input).sort.each do |word|
  breakdown = word.split("").map {|alpha_char| ENCODINGS[alpha_char] }.join("|")
  puts "#{word} -> #{breakdown}"
end
