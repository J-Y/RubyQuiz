class LongestRepeatedSubstring

  class Node
    attr_accessor :char, :next, :index
    def initialize(c,i)
      @char,@index = c,i
    end
  end

  @@nodes = []

  # Nodes are hashed by the substring starting at the 
  # node's position of a given length (the key_length).
  # Using a large key_length makes the search faster, but if
  # the largest repeated string is smaller than the key_length,
  # we won't find any repeated strings.  Hence we try a smaller 
  # key_length when a search fails.
  #
  # There doesn't appear to be much of a speed increase for key_length
  # above 30, at least for English text.

  def self.find(s)
    @@string = s
    self.build_nodes(s)
    31.step(1,-5) do |kl|
      lrs = self.find_using_key_length(kl)
      return lrs if lrs.length > 0
    end
    return ""
  end

 private

  def self.find_using_key_length (kl)
    long_len = 0
    long_node = nil
    self.build_node_hash(kl)
    @@node_hash.each do |k,v|
      0.upto(v.length-1) do |i|
        (v.length-1).downto(i+1) do |j|
          len = self.length_at (v[i],v[j])
          if len > long_len
            long_len, long_node = len, v[i]
          end
        end
      end
    end
    @@string.slice(long_node.index,long_len) rescue ""
  end 

  def self.build_nodes(s)
    prev = nil
    s.split(//).each_with_index do |c,i|
      curr = Node.new(c,i)
      prev.next = curr if prev
      @@nodes << curr
      prev = curr
    end 
  end

  def self.build_node_hash(key_length)
    @@node_hash = Hash.new { |h,k| h[k] = [] }
    @@nodes.each do |n|
      @@node_hash[@@string.slice(n.index,key_length)] << n if n.next
    end 
  end

  # Length of the longest substring starting at both node a and node b
  def self.length_at(a,b)
    len = 0
    b_index = b.index
    while b and a.char == b.char and a.index != b_index
      len += 1 
      a,b = a.next,b.next
    end
    len
  end

end

if __FILE__ == $0
  puts LongestRepeatedSubstring.find(STDIN.read)
end
