require 'graph'

module WordChains
  extend self
  
  class WordGraph
    include Graph
    
    def initialize(n, dict_file)
      @size = n
      @dict = {}
      dict_file.each_line do |line|
        word = line.chomp
        @dict[word] = true if word.size == @size
      end
    end
    
    def valid? word
      @dict[word]
    end
    
    def [](w1, w2)
      diff = false
      w1.split(//).each_with_index do |l, i|
        if l != w2[i,1]
          return nil if diff
          diff = true
        end
      end
      
      if diff
        1
      end
    end
    
    def each_successing_vertex(word)
      mod_word = word.dup
      word.split(//).each_with_index do |l, i|
        ('a'..'z').each do |other_letter|
          next if other_letter == l
          mod_word[i,1] = other_letter
          yield mod_word if @dict[mod_word]
        end
        mod_word[i,1] = l
      end
    end
    
    def directed?
      false
    end
  end
  
  def print_chain(root, target, dict)
    n = root.size
    die "both words must be of the same size" if n != target.size
      
    g = WordGraph.new(n, File.new(dict, 'r'))
    
    [root,target].each do |word|
      die "#{word} is not a dictionary word" unless g.valid? word
    end
      
    pred = {}
    res = g.dijkstra_shortest_paths({
      :root => root,
      :target => target,
      :predecessor => pred
    })
    
    if res    
      puts g.route(target, pred)
    else
      puts "no chain could be found"
    end
  end
  
  def die(msg)
    warn msg
    exit 1
  end
  
  def usage
    die "Usage: ruby #$0 START_WORD END_WORD [-d DICTIONARY]"
  end
  
  def run
    args = []
    dict = '/usr/share/dict/words'
    while arg = ARGV.shift
      if arg == '-d'
        dict = ARGV.shift or usage
      else
        args << arg
      end
    end
        
    usage if args.size != 2
    print_chain(args[0], args[1], dict)
  end
end

if $0 == __FILE__
  WordChains.run
end