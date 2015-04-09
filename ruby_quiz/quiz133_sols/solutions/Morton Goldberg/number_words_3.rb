WORD_LIST = "/usr/share/dict/words"
WORDS = File.read(WORD_LIST).split

def number_words(base=16, min_letters=3)
   biggest_digit = (?a + (base - 11))
   regex = /\A[a-#{biggest_digit.chr}]+\z/
   result = []
   WORDS.each do |w|
      next if w.size < min_letters || w =~ /^[A-Z]/
      break if w[0] > biggest_digit
      result << w if w =~ regex
   end
   result
end
