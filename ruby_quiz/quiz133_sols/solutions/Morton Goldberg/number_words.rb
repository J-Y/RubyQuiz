WORD_LIST = "/usr/share/dict/words"
WORDS = File.read(WORD_LIST).split

def number_words(base=16, min_letters=3)
   result = []
   WORDS.each do |w|
      next if w.size < min_letters || (?A..?Z).include?(w[0])
      break if w[0] > ?a + (base - 11)
      result << w if w.to_i(base).to_s(base) == w
   end
   result
end
