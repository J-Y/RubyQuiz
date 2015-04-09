module Huffman

  class Node

    attr_reader :sym, :wt, :parent
    def +(other_node)
      InternalNode.new(self, other_node)
    end

    def to_s
      "Node(#@sym, #@wt)"
    end

    def <=>(other)
      wt <=> other.wt
    end

    protected
    attr_writer :parent

  end

  class InternalNode < Node
    attr_reader :left, :right
    def initialize(child1, child2)
      @left, @right = *([child1, child2].sort)
      child1.parent = child2.parent = self
      @wt = child1.wt + child2.wt
      @sym = @left.sym + @right.sym
    end

=begin
    def <=>(other_node)
      other_node.cmp_with_internal(self)
    end

    def cmp_with_internal(other_node)
      other_node.wt <=> wt
    end

    def cmp_with_leaf(leaf)
      return 1 if leaf.wt == wt
      leaf.wt <=> wt
    end
=end

    def inspect
      "Node(#@sym, #@wt)"
    end

    def to_s
      indented(0)
    end

    def indented(indent)
      "#{("  " * indent)}#{inspect}\n#{left.indented(indent + 1)}\n#{right.indented(indent + 1)}"
    end

    def compute_hashes(encode_hash, decode_hash, path="")
      left.compute_hashes(encode_hash, decode_hash, path + "0")
      right.compute_hashes(encode_hash, decode_hash, path + "1")
    end

  end

  class LeafNode < Node

    def initialize(sym,wt)
      @sym, @wt = sym, wt
    end

    def indented(indent)
      "#{("  " * indent)}#{inspect}"
    end

    def inspect
      to_s
    end

    def compute_hashes(encode_hash, decode_hash, path="0")
      encode_hash[sym] = path
      decode_hash[path] = sym
    end

=begin
    def <=>(other_node)
      other_node.cmp_with_leaf(self)
    end

    def cmp_with_internal(other_node)
      return 1 if other_node.wt == wt
      other_node.wt <=> wt
    end

    def cmp_with_leaf(leaf)
      wt <=> leaf.wt
    end
=end

  end

  module ComparableQueue

    include Comparable

    def <=>(other)
      empty? ? 1 : other.wt_cmp(first.wt)
    end

    def wt_cmp(other_wt)
      empty? ? -1 : other_wt <=> first.wt
    end
  end

  class TreeGenerator

    private
    attr_accessor :histogram

    def histogram
      @histogram ||= Hash.new {|h,k| h[k] = 0}
    end

    def sorted_pairs
      histogram.to_a.sort_by {|a| a.last}
    end

    public
    def analyse(str)
      @root = @sorted = @encode_hash = @decode_hash = @code_pattern = nil
      str.scan(/./).each { | char |histogram[char] += 1}
    end

    def sorted_nodes
      @sorted ||= sorted_pairs
      @sorted.inject([]) {|nodes, pair| nodes << LeafNode.new(*pair)}
    end

    def lowest(q1, q2)
      q1 < q2 ? q1.shift : q2.shift
    end

    def generate_tree
      q1,q2 = sorted_nodes, []
      q1.extend(ComparableQueue)
      q2.extend(ComparableQueue)
      while (q1.size + q2.size) > 1
	q2 << InternalNode.new(lowest(q1,q2), lowest(q1,q2))
      end
      (q1+q2).first
    end

    def root
      @root ||= generate_tree
    end

    def compute_hashes
      @root ||= generate_tree
      @encode_hash = {}
      @decode_hash = {}
      @root.compute_hashes(@encode_hash, @decode_hash)
    end

    def encode_hash
      compute_hashes unless @encode_hash
      @encode_hash
    end

    def decode_hash
      compute_hashes unless @decode_hash
      @decode_hash
    end

    def code_pattern
      @code_pattern ||= %r{^(#{decode_hash.keys.join('|')})}
    end

    def encode(str)
      str.split(//).inject("") {|result, ch| result << encode_hash[ch]}
    end

    def decode(str)
      tmp = str.dup
      result = ""
      pat = code_pattern
      puts "pat is #{pat}"
      until tmp.empty?
	match = tmp.match(pat)
	result << decode_hash[match[1]]
	tmp = match.post_match
      end
      result
    end
  end
end

tg = Huffman::TreeGenerator.new
tg.analyse("ABRRKBAARAA") 
root = tg.generate_tree
puts root.to_s
puts "encode_hash = #{tg.encode_hash.inspect}"
puts "decode_hash = #{tg.decode_hash.inspect}"
puts "code_pattern = #{tg.code_pattern.inspect}"

encoded = tg.encode("ABRRKBAARAA")
puts "encoded = #{encoded}"
puts "decoded = #{tg.decode(encoded)}"
