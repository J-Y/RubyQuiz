# Justin Ethier
# August 2007
# Solution to Ruby Quiz #133 - Numbers can be words
 
# Create a regular expression to match all words in a number base
# The method basically generates a regex matching single words consisting
# of letters in the base. Matching is not case sensitive.
def get_regexp(base_num)
  # Get number of letters in the base
  num_letters = base_num - 10
  num_letters = 26 if num_letters > 26 # Cap at all letters in alphabet
  return nil if num_letters < 1        # Nothing would match
  
  # Create a regular expression to match all letters in the base
  end_c = ("z"[0] - (26 - num_letters)).chr # Move back from 'z' until reach last char in the base
  regexp_str = "^([a-#{end_c}])+$"          # Always starts at 'a'
  Regexp.new(regexp_str, "i")
end

# Read a list of words from file
def read_words_from_file(filename)
  words = []
   
  fp = File.new(filename)
  for line in fp.readlines
    words.push(line.strip)
  end
  fp.close
  
  words
end  

# "main" method
if ARGV.size != 3
  puts "Usage: words_as_numbers.rb word_file number_base minimum_word_length"
else
  word_file = ARGV[0] #"linux.words.txt"
  base = ARGV[1].to_i #22
  word_length = ARGV[2].to_i #8
  regexp = get_regexp(base)
  
  # Find all words  
  if (regexp != nil)
    for word in read_words_from_file(word_file)
      if word.size >= word_length
        puts word if regexp.match(word)
      end
    end
  end
end