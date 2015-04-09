# file: huffman.rb
# author: Drew Olson

require 'enumerator'

# class to hold nodes in the huffman tree
class Node
  attr_accessor :val,:weight,:left,:right

  def initialize(val="",weight=0)
    @val,@weight = val,weight
  end

  def children?
    return @left || @right
  end
end

# priority queue for nodes
class NodeQueue
  def initialize
    @queue = []
  end

  def enqueue node
    @queue << node
    @queue = @queue.sort_by{|x|[-x.weight,x.val.size]}
  end

  def dequeue
    @queue.pop
  end

  def size
    @queue.size
  end
end

# HuffmanTree represents the tree with which we perform
# the encoding
class HuffmanTree

  # initialize the tree based on data
  def initialize data
    @freqs = build_frequencies(data)
    @root = build_tree
  end

  #encode the given data
  def encode data
    data.downcase.split(//).inject("") do |code,char|
      code + encode_char(char)
    end
  end

  def decode data
    node = @root

    if !@root.children?
      return @root.val
    end

    data.split(//).inject("") do |phrase,digit|
      if digit == "0"
        node = node.left
      else
        node = node.right
      end
      if !node.children?
        phrase += node.val
        node = @root
      end
      phrase
    end
  end

  private

  # this method encodes a given character based on our
  # tree representation
  def encode_char char
    node = @root
    coding = ""

    # encode to 0 if only one character
    if !@root.children?
      return "0"
    end

    # we do a binary search, building the representation
    # of the character based on which branch we follow
    while node.val != char
      if node.right.val.include? char
        node = node.right
        coding += "1"
      else
        node = node.left
        coding += "0"
      end
    end
    coding
  end

  # get word frequencies in a given phrase
  def build_frequencies phrase
    phrase.downcase.split(//).inject(Hash.new(0)) do |hash,item|
      hash[item] += 1
      hash
    end
  end

  # build huffmantree using the priority queue method
  def build_tree
    queue = NodeQueue.new

    # build a node for each character and place in pqueue
    @freqs.keys.each do |char|
      queue.enqueue(Node.new(char,@freqs[char]))
    end

    while !queue.size.zero?

      # if only one node exists, it is the root. return it
      return queue.dequeue if queue.size == 1

      # dequeue two lightest nodes, create parent,
      # add children and enqueue newly created node
      node = Node.new
      node.right = queue.dequeue
      node.left = queue.dequeue
      node.val = node.left.val+node.right.val
      node.weight = node.left.weight+node.right.weight
      queue.enqueue node
    end
  end
end

# get command lines args, build tree and encode data
if __FILE__ == $0
  data = ARGV.join(" ")
  tree = HuffmanTree.new data

  # get encoded data and split into bits
  code = tree.encode(data)
  encoded_bits = code.scan(/\d{1,8}/)

  # output
  puts
  puts "Original"
  puts data
  puts "#{data.size} bytes"
  puts
  puts "Encoded"
  encoded_bits.each_slice(5) do |slice|
    puts slice.join(" ")
  end
  puts "#{encoded_bits.size} bytes"
  puts
  puts "%d percent compression" % (100.0 - (encoded_bits.size.to_f/data.size.to_f)*100.0)
  puts
  puts "Decoded"
  puts tree.decode(code)
end
