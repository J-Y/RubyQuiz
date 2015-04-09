#!/usr/bin/ruby -w

# Rubyquiz #44: Word Chains
# Levin Alexander <levin@grundeis.net>

require 'set'
require 'optparse'

$LETTERS = "a".."z"
$INFINITY = (1/0.0)
$DICTFILE = "/usr/share/dict/words"

# inefficient implementation of a priority queue
#
class SimpleQueue
  def initialize
    @storage = Hash.new { [] }
  end
  def insert(priority, data)
    @storage[priority] = @storage[priority] << data
  end
  def extract_min
    return nil if @storage.empty?
    key, val = *@storage.min
    result = val.shift
    @storage.delete(key) if val.empty?
    return result
  end
end

class String

  # returns a new string in which the character at index is
  # replaced with str
  #
  def replace_at(index, str)
    (new_string = self.dup)[index] = str
    return new_string
  end
  
  # yields each variation of the string in which exactly one 
  # character is changed
  #
  def each_neighbour
    length.times { |i|
      $LETTERS.each { |new_letter|
        new_word = replace_at(i, new_letter)
        yield new_word unless (self == new_word)
      }
    }
  end

  # amount of difference between two words.  Used in A* heuristics
  #
  def distance(other)
    return $INFINITY if other.nil?
    self.split(//).zip(other.split(//)).inject(0) { |i,z| 
      (z[0] == z[1]) ? i : i+1 
    }
  end
end

class WordChains
  include Enumerable

  def initialize(wordlist)
    @dictionary = Set.new(wordlist)
  end
  def include?(word)
    @dictionary.include?(word)
  end

  def from(word)
    # @wordmap stores the path to each word and how many permutations are 
    # needed to reach it.  Initially, no word is reachable
    @wordmap = Hash.new { { :prev => nil, :distance => $INFINITY } }
    # except we know how to reach the first word
    @wordmap[word] = {:distance => 0, :prev => nil}
    # initialize search queue by inserting the first word
    @queue = SimpleQueue.new
    @queue.insert(0, word)
    return self
  end

  def shortest_path_to(word)
    search(word) # search until target word is reached
    yield extract_path(word) if block_given?
    extract_path(word)
  end
  
  def each
    search # search for all reachable words
    @dictionary.each { |w| yield extract_path(w) if @wordmap[w][:prev] }
  end

  private

  # A* search through the dictionary.  Stop if a path to given word is found
  # or if search space is exhausted
  #
  def search(to = nil)
    while (last_word = @queue.extract_min)
      break if (last_word == to)
      depth = @wordmap[last_word][:distance] + 1
      each_edge(last_word) { |next_word|
        if @wordmap[next_word][:distance] > depth # avoid cycles
          @wordmap[next_word] = { :prev => last_word, :distance => depth }
          @queue.insert( depth + next_word.distance(to), next_word )
        end
      }
    end
  end
  
  # yields all words in the dictionary that differ from the given word by 
  # exactly one letter
  #
  def each_edge(word)
    word.each_neighbour { |neighbour|
      yield neighbour if @dictionary.include?(neighbour)
    }
  end
  
  # follows the :prev-pointer from the last word to the first one in the
  # chain.  Returns this path as an array -- or nil if no path exists
  #
  def extract_path(to)
    while (w = @wordmap[w || to][:prev]) do (arr ||= []).unshift(w) end
    return arr << to if arr
  end
end

# ---

if $0 == __FILE__

  OptionParser.new do |options|
    $LENGTH = nil
    options.on("-d", "--dict PATH") { |path| $DICTFILE = path }
    options.on("-l", "--length LENGTH") { |l| $LENGTH = l.to_i}
    options.on("-h", "--help") {
      puts "Usage:","`ruby #$0 [--dict PATH] [--length LENGTH] [from [to]]`";
      exit
    }
    options.parse! ARGV
  end

  $FROM, $TO = ARGV.shift, ARGV.shift
  
  warn "Loading dictionary..." if $DEBUG

  wordlist = IO.readlines($DICTFILE).collect{ |l| l.strip.downcase }.\
    grep(/^[a-z]+$/).reject{ |word| word.length != $LENGTH if $LENGTH }
  chains = WordChains.new(wordlist)
    
  warn "Searching chains..." if $DEBUG

  if $FROM && $TO
    # single chain to given word
    raise "#{$TO} is not in the dictionary" unless chains.include?($TO)
    chains.from($FROM).shortest_path_to($TO) { |path| puts path }
  elsif $FROM
    # all chains, sorted by length
    chains.from($FROM).sort_by { |x| x.length }.each { |path| 
      puts path.join(", ") 
    }
  else
    # find the longest chain in the dictionary
    longest_chain = wordlist.collect { |word|
      path = chains.from(word).max { |a,b| a.length <=> b.length }
      puts "> " + path.join(", ") if path and $DEBUG
      path
    }.compact.max { |a,b| a.length <=> b.length }
    
    warn "Longest chain is:" if $DEBUG
    unless longest_chain.nil?
      puts longest_chain.join(", ")
      puts longest_chain.length 
    end
  end

end
