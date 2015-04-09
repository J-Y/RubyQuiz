require 'rubygems'
require 'text'
require 'yaml'

## generate metaphones from wordlist
wordlist = File.readlines('wordlist').map {|l|l.chomp}

metaphones = {}

wordlist.each do |word|
  word.downcase!

  metaphone = Text::Metaphone.metaphone(word)
  (metaphones[metaphone] ||= []) << word
end

File.open("metaphones.dat", "w") {|f| f.write Marshal.dump(metaphones) }


## generate pronunciation hashes from pronunciation dictionary
pronunciations_search = {}
pronunciations = {}

File.open('cmudict') do |f|
  while line = f.gets
    next  if line =~ /^#/

    line.chomp =~ /^([^ ]+)\s+(.+)$/
    word, pronunciation = $1.downcase, $2

    (pronunciations_search[pronunciation] ||= []) << word
    pronunciations[word] = pronunciation
  end
end

File.open("pronunciations.dat", "w") {|f| f.write Marshal.dump(pronunciations) }
File.open("pronunciations_search.dat", "w") {|f| f.write Marshal.dump(pronunciations_search) }