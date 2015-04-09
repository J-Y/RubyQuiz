class DictionaryMatcher
  attr_reader :word_count
  @@hash_policy = lambda { {} }.freeze
  @@array_policy = lambda { [] }.freeze
  @@curr_policy = @@hash_policy
  
  def initialize(policy = :hash_policy)
    set_policy(policy)
    @trie = @@curr_policy.call
    @word_count = 0
  end
  
  def set_policy(sym)
    case sym
    when :hash_policy
      @@curr_policy = @@hash_policy
    when :array_policy
      @@curr_policy = @@array_policy
    else
      raise InvalidParameterError, "Invalid policy: #{sym.to_s}"
    end
  end
  
  def add_word(word)
    @word_count += 1
    container = @trie
    word.each_byte { |b| container[b] ||= @@curr_policy.call; container = container[b] }
    container[0] = true # Mark end of word
  end  
  
  def include?(word)
    container = @trie   
    word.each_byte { |b| break unless container[b]; container = container[b] }
    container[0]
  end
  
  def =~(text)
    pos = 0
    text_len = text.length
    
    while pos < text_len do
      container = @trie
      
       (pos...text_len).each do |i|
        b = text[i]
        break unless container[b]       
        container = container[b]
      end
      
      return pos if container[0] # Match
      pos += 1
    end
    
    nil
  end
  
  # Return containeray of matches in text [pos, len]
  def find_all_matching(text, &block)
    matches = []
    pos = 0
    text_len = text.length
    
    while pos < text_len do
      container = @trie
      len = 0
      
      pos.upto(text_len - 1) do |i|
        b = text[i]
        break unless container[b]       
        container = container[b]
        len += 1
      end
      
      if container[0] # Match
        if block
          block.call(pos, len)
        else
          matches << [pos, len]
        end
        pos += len # Skip over word
      else     
        pos += 1
      end
    end
    
    matches
  end
  
  # implement much of the rest of the interface implemented by Regexps
  alias_method :===, :=~
  alias_method :match, :=~
  alias_method :<<, :add_word
  
  # Add words from a file
  def add_words(words_file)
    IO.foreach(words_file) do |line|
      add_word line.chomp
    end
  end
end
