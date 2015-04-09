#!/usr/math/bin/ruby


module Huffman

  require 'rubygems'
  require 'priority_queue'
  require 'stringio'

  EndSymbol = "END"

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

    def depth
      1 + [left.depth, right.depth].max
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

    def depth
      1
    end

  end

  class NodeQueue
    def initialize
      @q = CPriorityQueue.new
    end

    def <<(node)
      q[node] = node.wt
    end

    def next
      q.delete_min_return_key
    end

    def size
      q.length
    end

    def first
      q.min_key
    end

    private
    attr_reader :q

  end

  class InputStream
    def initialize(pattern, length, sentinel)
      @pat, @len, @sentinel = pattern, length, sentinel
    end

    def eof?
      chunk.match(pat)[1] == sentinel
    end

    def next
      match = chunk.match(pat)
      self.chunk = match.post_match
      match[1]
    end

    protected
    attr_accessor :chunk, :pat, :sentinel
  end
  class EncoderOutputStream

    def initialize(sentinel)
      @sentinel = sentinel
      @buffer = ""
    end

    protected 
    attr_reader :sentinel
    attr_accessor :buffer
  end
  class FileOutputStream < EncoderOutputStream

    def initialize(file, sentinel)
      super(sentinel)
      self.file = file
    end

    def self.open(file_name, sentinel, &block)
      File.open(file_name, "w") do |file|
	fos = new(file, sentinel)
	begin
	  block.call(fos)
	ensure
	  fos.flush
	end
      end
    end

    def <<(str)
      buffer << str
      write_buffer
    end

    def flush
      write_buffer
      unless @buffer.empty?
	buffer << sentinel << "0"*8
	write_buffer
      end
    end

    private
    def write_buffer
      while self.buffer.length >= 8
	self.file << self.buffer[0..7].to_i
	self.buffer = self.buffer[8..-1]
      end
    end
  end

  class StringInput < InputStream
    def initialize(string, pattern, length, end_sentinel)
      @chunk = string
      super(pattern, length, end_sentinel)
    end
  end


  class TreeGenerator

    private
    attr_accessor :histogram

    def histogram
      @histogram ||= Hash.new {|h,k| h[k] = 0}
    end

    def initial_queue
      q = NodeQueue.new
      q << LeafNode.new(EndSymbol,0) # Special end symbol
      histogram.to_a.each do |sym_wt|
	q << LeafNode.new(*sym_wt)
      end
      q
    end

    public
    def analyse(str)
      @root = @encode_hash = @decode_hash = @code_pattern = nil
      str.scan(/./).each { | char |histogram[char] += 1}
    end


    def generate_tree
      queue = initial_queue
      while (queue.size) > 1
	queue << InternalNode.new(queue.next, queue.next)
      end
      queue.first
    end

  end

  class Codec

    attr_reader :root


    def initialize(tree)
      @root = tree
    end

    def compute_hashes
      @encode_hash = {}
      @decode_hash = {}
      root.compute_hashes(@encode_hash, @decode_hash)
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

    def encode_string(str)
      (str.split(//) << EndSymbol).inject("") {|result, ch| result << encode_hash[ch]}
    end

    def encode(input, output)
      input.each_byte {|byte| output << encode_hash[byte.chr]}
    end

    def decode(input, output)
      output << decode_hash[input.next] until input.eof?
    end

    def decode_string(source, sink="")
      input = source.huffman_decoder_input_stream(code_pattern, root.depth, encode_hash[EndSymbol])
      output = sink.huffman_decoder_output_stream
      decode(input, output)
      output.string
    end
  end
end

class String
  def huffman_decoder_input_stream(pat, length, end_sentinel)
    Huffman::StringInput.new(self, pat, length, end_sentinel)
  end

  def huffman_decoder_output_stream
    StringIO.new(self)
  end

end

