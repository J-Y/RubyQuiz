class String
  def chars
    split("")
  end
  def sorted
    chars.sort.join
  end
end

# Generate combinations.
def comb array, n, str = "", &blk
  0.upto(array.size - n){|i|
    if 1 == n
      yield str + array[i]
    else
      comb array[i+1..-1], n-1, str+array[i], &blk
    end
  }
end

word_groups = Hash.new {[]}
shorts = Hash.new {[]}
while word = gets do
  next unless (word=word.downcase.delete('^a-z')).size.between?(3,6)
  if 6 == word.size
    word_groups[word.sorted] += [ word ]
  else
    shorts[word.sorted] += [ word ]
  end
end

word_groups.each_key{|key|
  3.upto(5){|n|
    combinations = []
    comb( key.chars, n ){|s| combinations << s}
    combinations.uniq.each{|s| word_groups[key] += shorts[s] }}}
