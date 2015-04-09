require 'singleton'

class Word
 LETTERS = [ ['.-', 'A'], ['-.', 'N'], ['-...', 'B'], ['---', 'O'],
   ['-.-.', 'C'], ['.--.', 'P'], ['-..', 'D'], ['--.-', 'Q'], ['.', 'E'],
   ['.-.', 'R'], ['..-.', 'F'], ['...', 'S'], ['--.', 'G'], ['-', 'T'],
   ['....', 'H'], ['..-', 'U'], ['..', 'I'], ['...-', 'V'], ['.---', 'J'],
   ['.--', 'W'], ['-.-', 'K'], ['-..-', 'X'], ['.-..', 'L'], ['-.--', 'Y'],
   ['--', 'M'], ['--..', 'Z'] ]

 def initialize(word)
   @morse = word
 end
 def parse
   check_match(0, [], 0)
 end
 def check_match(word_offset, found_letters, found_letters_length)
   if found_letters_length == @morse.size
     word = found_letters.join('')      print word
     print ' *' if Dictionary.instance.has_word?(word)
     puts
     return
   end
   0.upto(LETTERS.size-1) do |index|
     morse_letter = LETTERS[index][0]
     next if word_offset + morse_letter.size > @morse.size
     if @morse[word_offset..(word_offset + morse_letter.size - 1)] == morse_letter
       check_match(word_offset + morse_letter.size, found_letters.clone.push(LETTERS[index][1]),
         found_letters_length + morse_letter.size)
     end
   end
 end

end

class Dictionary
 include Singleton

 def load
   @entries = {}
   File.open('/usr/share/dict/words') do |file|
     file.each_line do |line|
       @entries[line.chomp.upcase] = 1
     end
   end
 end
 def has_word?(word)
   @entries[word]
 end
end

Dictionary.instance.load

until $stdin.eof?
 Word.new($stdin.gets.chomp).parse
end
