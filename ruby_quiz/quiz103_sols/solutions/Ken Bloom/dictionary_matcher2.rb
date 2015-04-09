#based on Edwin Fine's solution, this reimplements my solution with
#less overhead all around.
class DictionaryMatcher
  attr_reader :word_count

  def initialize
    @trie = {}
    @word_count = 0
  end

  def add_word(word)
    @word_count += 1
    container = @trie
    containers=[]

    i=0
    word.each_byte do |b|
      container[b] = {} unless container.has_key? b
      container[:depth]=i
      containers << container
      container = container[b]
      i+=1
    end
    containers << container

    container[0] = true # Mark end of word

    ff=compute_failure_function word
    ff.zip(containers).each do |pointto,container|
      container[:failure]=containers[pointto] if pointto
    end

  end

  def compute_failure_function p
    m=p.size
    pi=[nil,0]
    k=0
    2.upto m do |q|
      k=pi[k] while k>0 and p[k] != p[q-1]
      k=k+1 if p[k]==p[q-1]
      pi[q]=k
    end
    pi
  end
  private :compute_failure_function

  def include?(word)
    container = @trie
    word.each_byte do |b|
      break unless container.has_key? b
      container = container[b]
    end
    container[0]
  end

  def =~ text
    internal_match text {|pos,len| return pos}
    nil
  end

  def internal_match string
      node=@trie
      pos=0
      string.each_byte do |b|
	 advance=false
	 until advance
	    nextnode=node[b]
	    if not nextnode
	       if node[:failure]
		  node=node[:failure]
	       else
		  advance=true 
	       end
	    elsif nextnode[0]
	       yield pos, nextnode[:depth] 
	       advance=true
	       node=@trie
	    else
	       advance=true
	       node=nextnode
	    end
	    pos+=1
	 end
      end
  end
  private :internal_match


  def find_all_matching(text, &block)
    matches=[]
    block= lambda{ |pos,len| matches << [pos,len] } unless block
    internal_match(text,&block)
    matches
  end

  alias_method :scan, :find_all_matching

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
