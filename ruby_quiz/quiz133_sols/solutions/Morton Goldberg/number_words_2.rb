WORD_LIST = "/usr/share/dict/words"
WORDS = File.read(WORD_LIST).split

def number_words(base=16, min_letters=3)
   WORDS.inject([]) do |result, w|
      next result if w.size < min_letters || (?A..?Z).include?(w[0])
      break result if w[0] > ?a + (base - 11)
      result << w if w.to_i(base).to_s(base) == w
      result
   end
end
