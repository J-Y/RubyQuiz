# A simple, stupid and not very efficient recursive depth-first
# solver, written using regular expressions.
#
# 28jul2007  +chris+

# Transpose a string
def flip(str)
  str.split("\n").map { |s| s.split(//) }.transpose.map { |s| s.join }.join("\n")
end

def wordlist(crossword)
  sizes = (     crossword .scan(/[A-Z]*_[A-Z_]+/) +
           flip(crossword).scan(/[A-Z]*_[A-Z_]+/)).
    map { |w| w.size }.uniq - [1]

  print "Gathering words... "
  all_words = File.read("/usr/share/dict/words").
    split("\n").                # save a chomp
    reject! { |w| not sizes.include?(w.size) }.
    map! { |w| w.upcase }
  puts "found #{all_words.size}"

  all_words
end

def solve(crossword, words=wordlist(crossword), flipped=false)
  # Is there a word to be filled?
  if crossword =~ /([A-Z]*_[A-Z_]+)/
    words.grep(Regexp.new("\\A#{$1.tr('_', '.')}\\z")).
      sort_by { rand }.         # faster results
      each { |fit|
        solve flip(crossword.sub(/[A-Z]*_[A-Z_]+/, fit)), words, !flipped
    }
  elsif flip(crossword) =~ /([A-Z]*_[A-Z_]+)/
    solve(flip(crossword), words, !flipped)
  elsif crossword !~ /_/        # fully filled?
    crossword = flip(crossword)  if flipped
    puts crossword
    puts
  end
end

def clean(crossword)
  crossword.delete(" \t").gsub(/\n{2,3}/, "\n")
end

# Test data

cw = <<EOF
	 _ _ _ _ _
	 
	 _ # _ # _
	 
	 _ _ _ _ _
	 
	 _ # _ # _
	 
	 _ _ _ _ _
EOF

cw2 = <<EOF
	 # # _ # # # # M
	 
	 _ _ _ _ _ _ # A
	 
	 # # _ # # _ # T
	 
	 R U B Y Q U I Z
	 
	 U # _ # # _ # #
	 
	 B # _ _ _ _ _ _
	 
	 Y # # # # _ # #
EOF

# Good luck with this one...
cw3 = <<EOF
	 _ _ _ _ # _ _ _ _ _ _ _ _ _ # _ _ _ _
	 
	 _ # _ # _ # _ # _ # _ # _ # _ # _ # _
	 
	 _ _ _ _ _ _ _ _ _ # _ _ _ _ _ _ _ _ _
	 
	 _ # _ # _ # _ # _ _ _ # _ # _ # _ # _
	 
	 # _ _ _ _ # _ # _ # _ # _ # _ _ _ _ #
	 
	 _ # _ # # # _ _ _ _ _ _ _ # # # _ # _
	 
	 _ _ _ _ _ _ # # _ # _ # # _ _ _ _ _ _
	 
	 _ # _ # # _ # _ _ _ _ _ # _ # # _ # _
	 
	 _ _ _ _ _ _ _ _ # _ # _ _ _ _ _ _ _ _
	 
	 _ # # _ # _ # _ _ _ _ _ # _ # _ # # _
	 
	 _ _ _ _ _ _ _ _ # _ # _ _ _ _ _ _ _ _
	 
	 _ # _ # # _ # _ _ _ _ _ # _ # # _ # _
	 
	 _ _ _ _ _ _ # # _ # _ # # _ _ _ _ _ _
	 
	 _ # _ # # # _ _ _ _ _ _ _ # # # _ # _
	 
	 # _ _ _ _ # _ # _ # _ # _ # _ _ _ _ #
	 
	 _ # _ # _ # _ # _ _ _ # _ # _ # _ # _
	 
	 _ _ _ _ _ _ _ _ _ # _ _ _ _ _ _ _ _ _
	 
	 _ # _ # _ # _ # _ # _ # _ # _ # _ # _
	 
	 _ _ _ _ # _ _ _ _ _ _ _ _ _ # _ _ _ _
EOF

solve(clean(cw2))
