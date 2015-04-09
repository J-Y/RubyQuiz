require "pp"
require "set"

$stdout.sync = true # rubyeclipse requires it

class Trie
  def initialize
    @containers = Set.new
    @tries = Hash.new
  end

  def containers(word)
    if word.length == 0 then
      return @containers
    end
    trie = @tries[ word[0,1] ]
    return trie ? trie.containers(word[1...word.length]) : Set.new
  end

  def add(word, index)
    if word.length == 0 then
      @containers << index
    else
      # word[0,1] returns a String. word[0] returns a number (yack!)
      trie = @tries[ word[0,1] ] ||= Trie.new
      trie.add( word[1...word.length], index )
    end
  end
end

class Indexer
  def initialize( texts )
    @trie = Trie.new
    texts.each do
      |t|
      t.split.each do
        |w|
        @trie.add(w.capitalize, t)
      end
    end
  end

  def containers(word)
    @trie.containers(word.capitalize)
  end
end

texts = ["The quick brown fox", "Jumped over the brown dog", "Cut him
to the quick"]

indexer = Indexer.new(texts)
puts "containers for \"the\""
pp indexer.containers('the') # -> ["The quick brown fox", "Jumped over
the brown dog", "Cut him to the quick"]
puts "containers for \"brown\""
pp indexer.containers('brown') # -> ["The quick brown fox", "Jumped
over the brown dog"]
puts "containers for \"inexistant\""
pp indexer.containers('inexistant') #-> []
