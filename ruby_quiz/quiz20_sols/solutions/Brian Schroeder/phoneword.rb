#!/usr/bin/ruby
#
# = The quiz description:
#
# Many companies like to list their phone numbers using the letters printed on
# most telephones.  This makes the number easier to remember for customers.  A
# famous example being 1-800-PICK-UPS.
#
# This week's quiz is to write a program that will show a user possible matches
# for a list of provided phone numbers.
#
# Your script should behave as a standard Unix filter, reading from files
# specified as command-line arguments or STDIN when no files are given.  Each line
# of these files will contain a single phone number.
#
# For each phone number read, your filter should output all possible word
# replacements from a dictionary.  Your script should try to replace every digit
# of the provided phone number with a letter from a dictionary word; however, if
# no match can be made, a single digit can be left as is at that point.  No two
# consecutive digits can remain unchanged and the program should skip over a
# number (producing no output) if a match cannot be made.
#
# Your script should allow the user to set a dictionary with the -d command-line
# option, but it's fine to use a reasonable default for your system.  The
# dictionary is expected to have one word per line.
#
# All punctuation and whitespace should be ignored in both phone numbers and the
# dictionary file.  The program should not be case sensative, letting "a" == "A". 
# Output should be capital letters and digits separated at word boundaries with a
# single dash (-), one possible word encoding per line.  For example, if your
# program is fed the number:
#
#   873.7829
#
# One possible line of output is
#
#   USE-RUBY
#
# According to my dictionary.
#
# The number encoding on my phone is:
#
#   2 = A B C
#   3 = D E F
#   4 = G H I
#   5 = J K L
#   6 = M N O
#   7 = P Q R S
#   8 = T U V
#   9 = W X Y Z
#
# Feel free to use that, or the encoding on your own phone.
#
# = My Solution
# http://ruby.brian-schroeder.de/quiz/phoneword/
#
# = License
# GPL

# Nodes in the Dictionary.
class DictionaryNode < Array
  # Terminal info
  attr_reader :words

  def initialize
    super(10)
    @words = []
  end
end

# A tree-indexed version of the dictionary that allows efficent searching by number 2 alphabet mapping.
class Dictionary
  def initialize(encoding)
    super()   
    @encoding = {}
    @inverse_encoding = {}

    encoding.each do | k, v |
      @encoding[k] = v.split(/\s+/).map{|c| c[0]}
    end

    # Create map from characters to numbers
    @inverse_encoding = @encoding.inject({}) { | r, (k, v) |
      v.each do | l | r[l] = k end
      r
    }
    @root = DictionaryNode.new
  end

  # Helper method for rekursive adding of words to the dictionary
  private
  def add_recursive(node, word, position)
    if word.length == position
      node.words << word
      return node
    end
    add_recursive(node[@inverse_encoding[word[position]]] ||= DictionaryNode.new, word, position + 1) 
  end

  # Add words to the dictionary
  public
  def add(word)
    add_recursive(@root, word, 0)
    self
  end
  
  # Load a wordlist from a file, which contains one word per line.
  # Ignores punctuation and whitespace.
  def load_wordlist(file, options)
    $stderr.print "Loading dictionary... " if options.verbose
    start = Time.new
    file.read.gsub(/[^A-Za-z\n]/, '').upcase!.split($/).uniq!.each do |w|
      w.chomp!
      next if w.empty? or w.length <= options.min_length
      self.add(w)
    end
    $stderr.puts "built dictionary in %f seconds" % (Time.new-start).to_f if options.verbose
    self      
  end

  private
  # Search words and return (in the block) words and the unmatched rest of the number
  def sub_find(node, number, &block)
    # Return words found so far
    block[node.words.map{|w|w.dup}, number] unless node.words.empty?
    # No more digits, so stop searching here
    return node if number.empty?
    # Search for longer words
    sub_find(node[number[0]], number[1..-1], &block) if node[number[0]]   
  end

  private
  # Calculate all allowed skip patterns for a number of a given length
  def skips(s, length)
    return [s] if length == 0
    result = skips(s + [false], length-1)
    result.concat(skips(s + [true], length-1)) unless s[-1]
    result
  end

  public
  # Skipping makes this a bit ugly
  def find_noskip(number)
    result = []
    sub_find(@root, number) do | words, rest_number |
      if rest_number.empty?
        result.concat(words)
      else
        find_noskip(rest_number).each do | sentence |
          words.each do | w |
            result << w + '-' + sentence
          end
        end
      end
    end
    result
  end 

  # Skipping makes this a bit ugly
  def find(number)
    result = []
    skips([], number.length).each do | skipped |

      # Create the injector that can inject the skipped numbers back into the word
      injector = []
      skipped.zip(number).each_with_index do |(s,n), i|
        injector << [n.to_s, i] if s
      end

      # We search for words built from the unskipped digits
      unskipped_digits = number.zip(skipped).select{|(d, s)| !s}.map{|(d,s)|d}
      sentences = find_noskip(unskipped_digits)
      # Inject the skipped digits back into the found sentences
      sentences.each do | s |
        injector.each do | (n, i) | s.insert(i, n) end
      end

      result.concat(sentences)
    end
    result
  end
end

encodings = {
  :james => {
    2 => 'A B C',
    3 => 'D E F',
    4 => 'G H I',
    5 => 'J K L',
    6 => 'M N O',
    7 => 'P Q R S',
    8 => 'T U V',
    9 => 'W X Y Z'},

  :logic => {
    0 => 'A B',
    1 => 'C D',
    2 => 'E F',
    3 => 'G H',
    4 => 'I J K',
    5 => 'L M N',
    6 => 'O P Q',
    7 => 'R S T',
    8 => 'U V W',
    9 => 'X Y Z'
  }
}

require 'optparse'

class PhonewordOptions < OptionParser
  attr_reader :dictionary, :encoding, :format, :allow_skips, :help, :encoding_help, :verbose, :min_length
  def initialize
    super()
    @dictionary = '/usr/share/dict/words'
    @encoding = :james
    @format = :plain
    @allow_skips = true
    @help = false
    @encoding_help = false
    @verbose = false
    @ignore_non_alpha = false
    @min_length = 1
    self.on("-d", "--dictionary DICTIONARY", String) { | v | @dictionary = v }
    self.on("-e", "--encoding ENCODING", String,
            "How the alphabet is encoded to phonenumbers. james or logic are supported.") { | v | @encoding   = v.downcase.to_sym }
    self.on("-p", "--plain", 'One result per found number, no other information. (Default)') { @format = :plain }
    self.on("-f", "--full", 'Prefix the result with the number')               { @format = :full }
    self.on("-v", "--verbose", 'Make more noise')               { @verbose = true }
    self.on("-s", "--skips", "--allow_skips", "--allow-skips", 'Allow to skip one adjacent number while matching. (Default)',
            'Gives lots of ugly results, but james asked for it.')   { @allow_skips  = true }
    self.on("-c", "--no-skips", "Don't leave numbers in the detected words") { @allow_skips  = false }
    self.on("-m" "--min-length", "Minimum length of accepted words.",
              "Use this to ignore one-letter words that make the output quite uninteresting.", Integer) { | v | @min_length  = v }
    self.on("-?", "--help") { @help = true }
    self.on("--supported-encodings", "--encoding-help", "List the supported encodings") { @encoding_help = true }
  end
end

options = PhonewordOptions.new
options.parse!(ARGV)

if options.help
  puts options
  exit
end

if options.encoding_help or !encodings[options.encoding]
  puts "Possible encodings:"
  puts encodings.to_a.sort_by{|(k,v)|k.to_s}.map{|(k,v)| "#{k}:\n"+v.map{|(n,e)|"  #{n}: #{e}"}.sort.join("\n")}
  exit
end

dictionary = Dictionary.new(encodings[options.encoding]).load_wordlist(File.open(options.dictionary), options)

output = {
  :plain   => lambda do | number, sentence | sentence end,
  :full => lambda do | number, sentence | "#{number.ljust(15)}: #{sentence}" end }

method = {true => :find, false => :find_noskip }

ARGF.each do | number |
  number.strip!
  number = number.gsub(/[^0-9]/, '').unpack('C*').map{|n|n - ?0}
  $stderr.puts "Searching for #{number}" if options.verbose
  dictionary.send(method[options.allow_skips], number).each do | sentence |
    puts output[options.format][number, sentence]
  end
end
