# Author: Lou Scoras <louis.j.scoras@gmail.com>
# Date:   Sun Nov 26 10:43:34 EST 2006
#
# q103.rb - Solution to Rubyquiz 103 (DictionaryMatcher)
#
# Implements DictionaryMatcher using a Trie.  This version of
# DictionaryMatcher only matches complete words, but it wouldn't
# be too hard to modify to match any substring.

class Trie
 def initialize
   @children = Hash.new {|h,k| h[k] = Trie.new}
 end

 attr_accessor :value

 def []=(key, value)
   insert(key, 0, value)
   key
 end

 def [](key)
   get(key,0)
 end

 def each &blk
   _each &blk
 end

 include Enumerable

 def keys
   inject([]) {|keys,(k,v)| keys << k; keys}
 end

 def values
   inject([]) {|vals,(k,v)| vals << v; vals}
 end

 def each_key &blk
   keys.each &blk
 end

 def each_value &blk
   values.each &blk
 end

 def inspect(indent=0)
   buff = ''
   i = ' ' * indent
   buff << i + "value: #{value}\n" if value
   return buff unless @children.size > 0
   @children.each {|k,c|
     buff << "#{i}#{k} =>\n"
     buff << c.inspect(indent+2)
   }
   buff
 end

 protected

 def _each(key='', &blk)
   blk.call(key,value) if key != '' and value
   @children.keys.sort.each do |k|
     @children[k]._each(key + k,&blk)
   end
 end

 def insert(key,offset,value)
   if offset == key.length - 1
     @children[key[offset,1]].value = value
   else
     @children[key[offset,1]].insert(key,offset+1,value)
   end
 end

 def get(key,offset)
   if offset == key.length - 1
     @children[key[offset,1]].value
   else
     return nil unless @children.has_key?(key[offset,1])
     @children[key[offset,1]].get(key,offset+1)
   end
 end
end

class DictionaryMatcher
 def initialize(opts={})
   @ignore_case = opts[:ignore_case]
   @trie = Trie.new
 end

 def ignores_case?
   @ignore_case
 end

 def <<(word)
   word = word.downcase if ignores_case?
   @trie[word] = true
 end

 def words
   @trie.keys
 end

 def include?(word)
   !@trie[(ignores_case?? word.downcase : word)].nil?
 end

 def =~(string)
   words = string.split
   positions = words.inject({}) { |h,w|
     h[w] = string.index(w) unless h[w]; h
   }
   words.each do |word|
     return positions[word] if
	 include?(ignores_case?? word.downcase : word)
   end
   return nil
 end

 alias_method :===,   :=~
 alias_method :match, :=~
end
