#!/usr/bin/ruby -w -Ku

# Build a chain of words, where each next word in the chain changes only one letter against the former.
#
# Why is my solution fast:
# 1) I use the A* algorithm
# 2) I use a real priority queue implemented in C with:
#      amortized O(1) insert, decrease_priority
#      amortized O(log n) delete_min  
#
# I calculate the neighbours lazily when needed.
# I use a nifty partitioning of the words that makes neighbour calculation
# a union of only word-length set.

# TODO: Refaktor Search Algorithms into own unit
require 'priority_queue'
require 'set'

### THE WORKER ###

# The word-graph
class WordNet

  # Load the words partitioned by length. Neighbour calculation is done on demand.
  def initialize(*words)
    @words_by_length = Hash.new { | h, k | h[k] = Set.new }
    @similar_words = Hash.new { | h, k | h[k] = Set.new }
    @similar_words_build = Hash.new
    @neighbours = Hash.new
    words.flatten.each do | word |      
      next if /[-'?!+\/_.:,]/ =~ word
      @words_by_length[word.length] << word
    end
  end

  # Load dictionary into wordgraph
  def self.load(file)
    words = File.read(file).split($/)
    words.each do | w | w.downcase! end
    self.new( words )
  end

  # Calculate the neighbours. This lazily calculates neighbourhood sets and saves results for later lookup.
  def neighbours(word)
    unless @similar_words_build[word.length]
      @words_by_length[word.length].each do | w |
	word.length.times do | l |
	  @similar_words[w[0,l] << '_' << w[l+1..-1]] << w 
	end
      end
      @similar_words_build[word.length] = true
    end

    #puts "Searching neighbours for #{word}"
    @neighbours[word] ||= (0...word.length).inject(Set.new) { | r, l | r.merge(@similar_words[word[0,l] + '_' + word[l+1..-1]]) }.delete(word)
  end

  # Append an additional word to the dictionary.
  def <<(word)
    @words_by_length[word.length] << word
    @similar_words_build[word.length] = false
    @neighbours[word] = nil
    self
  end

  private
  # Helper function to retrieve a path from a parent-hash
  def gather_parents(node, parents)
    if parents[node]
      gather_parents(parents[node], parents) << node
    else
      [node]
    end
  end

  public
  INFINITY = 1.0/0.0

  # The A* Algorithm
  def find_chain(word1, word2)
    queue = PriorityQueue.new
    parent   = Hash.new
    distance = Hash.new{|h,k| INFINITY}
    closed   = Hash.new{|h,k| INFINITY}

    queue.push(word1, 0)
    distance[word1] = 0

    word2_letters = word2.split(//)

    while word = queue.pop_min
      closed[word] = distance[word]
      self.neighbours(word).each do | n1 |
	n1_distance = distance[word] + 1
	next if distance[n1] <= n1_distance or closed[n1] <= n1_distance
	distance[n1] = n1_distance
	parent[n1] = word
	h = word2_letters.zip(word.split(//)).inject(0) { | d, (a, b) | a == b ? d : d + 1 }
	queue.push(n1, n1_distance + h)
      end
    end

    gather_parents(word2, parent) if parent[word2]
  end
end

if __FILE__ == $0
  ### Option Parsing ###
  require 'optparse'

  class WordChainOptions < OptionParser
    attr_reader :database, :help, :words

    def initialize
      super()
      @database = '/usr/share/dict/words'
      self.banner = "Usage: wordchain [-d DICT] FROM TO [TO_2 ... TO_N]"
      self.on("-d FILENAME", "--dict FILENAME", String)  { | v | @database   = v }
      self.on("-?", "--help")                   {       @help       = true }
    end

    def parse!(*args)
      super
      raise "Need a from and a to argument" unless ARGV.length >= 2
      @words = *ARGV
    end
  end

  options = WordChainOptions.new
  begin
    options.parse!(ARGV)
  rescue => e
    puts "Invalid Commandline Arguments"
    puts e
    puts options
    exit
  end

  if options.help 
    puts options
    exit
  end

  ### Make him work ###

  warn "Loading database"
  wordnet = WordNet.load(options.database)

  options.words[0..-2].zip(options.words[1..-1]) do | from, to |
  warn "Searching connection between #{from} and #{to}"
    puts wordnet.find_chain(from, to)
    puts
  end
end
