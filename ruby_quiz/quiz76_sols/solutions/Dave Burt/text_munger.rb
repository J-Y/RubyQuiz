#
# Text Munger/Unmunger - Ruby Quiz #76
#
# Normally acts as a filter, shuffling the middle letters of words:
#
#   Now terhe is a fnial rseaon I thnik that Jsues syas, "Lvoe your emneies."...
# 
# Alternatively, if the --unmunge parameter is given, un-munges using a
# (hard-coded) dictionary.
#
# Author: dave at burt.id.au
# Created: 22 Apr 2006
# Last modified: 24 Apr 2006
#

words_file = 'dict.txt' # /usr/share/words

# Return a function that uses f to sort the letters in its parameter w
def rearrange(&f)
  proc {|w| w[0,1] + w[1..-2].split(//).sort_by(&f).join + w[-1,1] }
end

# Replace each word from ARGF with f.call(w) and write to standard output
def filter(&f)
  ARGF.each {|s| puts s.gsub(/[a-z]{4,}/i, &f) }
end

if ARGV[0] == '--unmunge' || ARGV[0] == '-u'
  ARGV.shift                      # remove -u parameter
  sort = rearrange {|a| a }       # sort arranges middle letters alphabetically
  dict = Hash.new {|h, k| k }     # dict returns the key if lookup fails
  File.foreach(words_file) {|w| w.chomp!; dict[sort[w]] = w }
  filter {|w| dict[sort[w]] }
else
  filter &rearrange { rand }
end
