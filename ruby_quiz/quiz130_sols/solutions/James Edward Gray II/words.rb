#!/usr/bin/env ruby -wKU

WORDS_CASH_FILE = "words.cache"

if File.exist? WORDS_CASH_FILE
  WORDS = File.open(WORDS_CASH_FILE) { |file| Marshal.load(file) }
else
  WORDS = File.open( ARGV.find { |arg| arg =~ /\A[^-]/ } ||
                     "/usr/share/dict/words" ) do |dict|
    dict.inject(Hash.new) do |all, word|
      all.update(word.delete("^A-Za-z").downcase => true)
    end.keys.sort_by { |w| [w.length, w] }
  end
  File.open(WORDS_CASH_FILE, "w") { |file| Marshal.dump(WORDS, file) }
end
