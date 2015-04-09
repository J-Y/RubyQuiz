# Ruby Quiz #76 - Text Munger by Michael Brum
# 
# Usage: ruby rq76-munger.rb text_file.txt
#
# It seems to me that once a word gets past a certain length
# the readability of that word once munged drops conciderably.
# In trying to take that into account, for words over 8 characters
# in length, I split the middle section into two strings and munge
# those separately. 

def munge(word)
  case word.length
    when 0..3: return word
    when 4..8: return word[0].chr + word[1,(word.length-2)].split(//).to_a.sort_by{rand}.to_s + word[word.length-1].chr
    else       return word[0].chr + word[1,(word.length/2)].split(//).to_a.sort_by{rand}.to_s + word[(word.length/2),(word.length-2)].split(//).to_a.sort_by{rand}.to_s + word[(word.length-1)].chr
  end
end

mtext = String.new()
File.open(ARGV[0]) do |file|
line = file.gets(separator=nil)
  line.split(/([^A-Za-z])/).each do |word|
    mtext += munge(word)
  end
  puts mtext
end