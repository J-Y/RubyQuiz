# Ruby Quiz 123
# Donald Ball

require 'optparse'
require 'stringio'

module Huffman

  EOS = "\000" # end of string character for binary decoding

  class Leaf
    @code = 1
    
    class << self
      attr_reader :code
    end

    attr_reader :char, :weight
  
    def initialize(char, weight)
      @char = char
      @weight = weight
    end
  
    def ==(other)
      self === other && @weight == other.weight
    end
  
    def ===(other)
      other.is_a?(Leaf) && @char == other.char
    end
  
    def ciphers(hash, prefix)
      hash[char] = prefix
    end

    def serialize
      yield self.class.code
      yield char
    end
  end
  
  class Branch
    @code = 0

    class << self
      attr_reader :code
    end

    attr_reader :left, :right
  
    def initialize(left, right)
      @left = left
      @right = right
    end
  
    def weight
      left.weight + right.weight
    end
  
    def ciphers(hash = {}, prefix = '')
      left.ciphers(hash, prefix + '0')
      right.ciphers(hash, prefix + '1')
      hash
    end
  
    def ===(other)
      other.is_a?(Branch) && @left === other.left && @right === other.right
    end
  
    def ==(other)
      other.is_a?(Branch) && @left == other.left && @right == other.right
    end

    def serialize(&blk)
      yield self.class.code
      left.serialize(&blk)
      right.serialize(&blk)
    end
  end

  class Tree
    attr_reader :root, :plaintext

    # returns a hash of weights by character, adding EOS char with weight 0
    def self.char_freq(src)
      src.split(//m).inject(Hash.new(0)) {|m, c| m[c] += 1; m}.merge({EOS=>0})
    end

    # returns a sorted array of arrays of weights and chars
    def self.sort_freq(src)
      char_freq(src).map {|c, v| Leaf.new(c, v)}.sort_by {|l| [l.weight, l.char] }
    end

    # shifts the next smallest node from the two given arrays
    def self.next_smallest(l1, l2)
      return l1.shift if l2.length == 0
      return l2.shift if l1.length == 0
      l1[0].weight <= l2[0].weight ? l1.shift : l2.shift
    end
  
    def initialize(src)
      raise if src.nil?
      if src.is_a?(Branch) || src.is_a?(Leaf)
        @root = src
        return
      end
      @plaintext = src
      leaves = self.class.sort_freq(plaintext)
      branches = []
      until leaves.length + branches.length == 1
        n1 = self.class.next_smallest(leaves, branches)
        n2 = self.class.next_smallest(leaves, branches)
        branches << Branch.new(n1, n2)
      end
      @root = branches[0]
    end

    def ==(other)
      @root == other.root
    end

    def ===(other)
      @root === other.root
    end

    def serialize(&blk)
      @root.serialize(&blk)
      ciphers = @root.ciphers
      @plaintext.split(//m).each {|char| yield [ciphers[char]] }
      yield [ciphers[EOS]]
    end
  end
  
  # encodes and decodes strings to strings of mostly 0s and 1s, prepending
  # the dictionary
  class StringEncoder
    def self.encode(plaintext)
      tree = Tree.new(plaintext)
      bits = ''
      tree.serialize do |x| 
        bits << 
          case x
            when Fixnum: x.to_s
            when Array: x[0]
            else x.unpack('B8')[0]
          end
      end
      bits << '0' * ((8 - (bits.length % 8)) % 8)
    end

    def self.decode(src)
      ios = StringIO.new(src)
      root = decode_tree(ios)
      deciphers = root.ciphers.invert
      s = ''
      buffer = ''
      while bit = ios.read(1)
        buffer << bit
        if char = deciphers[buffer]
          break if char == EOS
          s << char
          buffer = ''
        end
      end
      s
    end

    def self.decode_tree(ios)
      case ios.read(1)
        when Branch.code.to_s
          Branch.new(decode_tree(ios), decode_tree(ios))
        when Leaf.code.to_s
          Leaf.new([ios.read(8)].pack('B8'), 0)
        else
          raise
      end
    end
  end

  # encodes and decodes strings to binary, prepending the dictionary
  class BinaryEncoder
    def self.encode(src)
      [StringEncoder.encode(src)].pack('B*')
    end

    def self.decode(src)
      StringEncoder.decode(src.unpack('B*')[0])
    end
  end

end

if $0 == __FILE__
  options = {}
  OptionParser.new do |opts|
    opts.on('-b', '--binary', 'Use binary encoding') do |s|
      options[:encoder] = Huffman::BinaryEncoder
    end
    opts.on('-d', '--decode', 'Decode') do |d|
      options[:action] = :decode
    end
    opts.on('-f F', '--file', String, 'File input') do |f|
      input = ''
      File.open(f, 'r') do |file|
        file.each_line do |line|
          input += line
        end
      end
      options[:input] = input
    end
  end.parse!
  options[:encoder] ||= Huffman::StringEncoder
  options[:action] ||= :encode
  options[:input] ||= $stdin.read
  $stdout.write options[:encoder].send(options[:action], options[:input])
end