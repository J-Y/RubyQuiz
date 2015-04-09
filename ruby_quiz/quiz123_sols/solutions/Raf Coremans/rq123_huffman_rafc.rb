#!/usr/bin/ruby -w
#
#There's some quick'n'dirty things in here that could be ironed out...

module Huffman
  #The token that indicates the end of the message
  TERMINATOR = "{#%eNdOfMeSsAgE}#%" #Weird string to minimize probability of collision with existing token

  #One node of a Huffman Tree. Has a "0" branch and a "1" branch.
  #Each branch either points to a token or to another Node
  class Node
    attr_reader :branches
    def initialize( branch0, branch1)
      @branches = [branch0, branch1]
    end

    def walk( path_so_far, &block)
      @branches.each_with_index do |branch, i|
        new_path = path_so_far.dup << i
        if branch.is_a?( Node)
          branch.walk( new_path, &block)
        else
          yield new_path, branch
        end
      end
    end

    def inspect
      "<#{self.class}: 0=>#{@branches[0]}, 1=>#{@branches[1]}>"
    end
  end #class Node

  #A Huffman tree
  #Leafs are tokens; path to token is Huffman code of token
  class Tree
    include Enumerable

    def initialize( tokens)
      raise ArgumentError.new( "No tokens given.") unless tokens

      if tokens.include?( TERMINATOR)
        warn "Input contains the end-token. Results will be incorrect!"
      end
      frequencies = (tokens.dup << TERMINATOR).inject( Hash.new( 0)){ |h, token| h[token] += 1; h}

      #And here we build the actual tree
      while frequencies.size > 1 #As long as we haven't brought everything together into one tree
        #Find lowest two frequencies, remove them...
        lows = []
        2.times do |i|
          low = frequencies.inject(){ |min, freq| min = freq if freq[1] < min[1]; min }
          frequencies.delete( low[0])
          lows << low
        end
        #...and combine them into one Node
        node = Node.new( lows[0][0], lows[1][0])
        #Push node into the hash, with the combined frequency being the
        #sum of the two frequencies
        frequencies[node] = lows[0][1] + lows[1][1]
      end
      #Now the hash contains the root node of the tree
      @root_node = frequencies.keys[0]
    end #method initialize

    def each( &block)
      @root_node.walk( [], &block)
    end

    def inspect
      "<#{self.class}: #{inject( {}){|h, code_token| h[code_token[1]] = code_token[0]; h}.inspect}>"
    end
    
    #Encode: encodes an array of tokens and writes
    #the result to outputstream
    def encode( tokens, outputstream)
      #Helper method on outputstream to write single bits
      class << outputstream
        def init
          @byte = 0
          @bit_count = 0
        end
        def write_bit( bit)
          @byte += bit
          @bit_count += 1
          if 8 == @bit_count
            write( @byte.chr)
            init
          else
            @byte <<= 1
          end
        end
        def fill_up
          if 0 < @bit_count
            (8 - @bit_count).times { write_bit( 0) }
          end
        end
      end
  
      token_to_code = {}
      each{ |code, token| token_to_code[token] = code}
  
      if tokens.include?( TERMINATOR)
        warn "Input contains the end-token. Results will be incorrect!"
      end
  
      outputstream.init
      (tokens.dup << TERMINATOR).each do |token|
        #Not going for the extra credit: I don't encode by walking the tree
        code = token_to_code[token]
        raise ArgumentError.new( "Token #{token.inspect} not found in tree") unless code
        code.each{ |bit| outputstream.write_bit( bit) }
      end
      outputstream.fill_up
    end #method encode

    #Decode: decodes a stream of bits to an array of tokens
    def decode( inputstream)
      #Helper method on inputstream to read single bits
      class << inputstream
        def init
          @byte = 0
          @bit_count = 0
        end
        def read_bit
          if 0 == @bit_count
            @byte = read( 1)[0]
            @bit_count = 8
          end
          bit = @byte & 0b10000000 == 0 ? 0 : 1
          @bit_count -= 1
          @byte <<= 1
          return bit
        end
      end
  
      inputstream.init
      node = @root_node
      tokens = []
      loop do
        bit = inputstream.read_bit
        branch = node.branches[bit]
        if branch.is_a?( Node)
          node = branch
        else
          token = branch
          break if TERMINATOR == token
          tokens << token
          node = @root_node
        end
      end
      tokens
    end #method decode
  end #class Tree

  #Abstract Tokenizer: splits input into tokens
  class Tokenizer
    def self.tokenize( *args)
      raise NotImplementedError.new( "Need a *concrete* Tokenizer")
    end
    def self.untokenize( tokens)
      tokens.join( '')
    end
  end #class Tokenizer

  #Here's an example of a concrete Tokenizer
  class StringToByteTokenizer < Tokenizer
    def self.tokenize( *args)
      to_be_tokenized = args[0]
      to_be_tokenized.to_s.split( //)
    end
  end #class StringToByteTokenizer

  #And some more...
  class StringToWordTokenizer < Tokenizer
    def self.tokenize( *args)
      to_be_tokenized = args[0]
      tokens = []
      t = to_be_tokenized.dup
      t.gsub!( /(^|\b)([\d\D]+?)\b/m){ |m| tokens << m; ''}
      tokens << t
    end
  end #class StringToWordTokenizer

  class StringToMultiByteTokenizer < Tokenizer
    require 'enumerator'
    def self.tokenize( *args)
      to_be_tokenized = args[0]
      multiple = args[1]
      tokens = []
      to_be_tokenized.split( //).each_slice( multiple){ |s| tokens << s}
      tokens
    end
  end #class StringToMultiByteTokenizer

end #module Huffman

########################
#Main:
########################

data_file = 'big.txt' #http://norvig.com/big.txt

MAX_SIZE = 500_000 #Limit size to keep runtime reasonable...
data = open( data_file).read( MAX_SIZE)
data_size = data.size

#Try several tokenizers
[
  ['byte',  Huffman::StringToByteTokenizer,      nil],
  ['word',  Huffman::StringToWordTokenizer,      nil],
  ['2byte', Huffman::StringToMultiByteTokenizer, 2  ],
  ['3byte', Huffman::StringToMultiByteTokenizer, 3  ]
].each do |label, tokenizer, extra_arg|
  tokens = tokenizer.tokenize( data, extra_arg)
  tree = Huffman::Tree.new( tokens)
  #p tree.inspect
  #p tree.

  #Persist the tree
  tree_file = data_file + '.' + label + '.tree'
  open( tree_file, 'w') { |f| f.write( Marshal.dump( tree)) }

  #Encode
  enc_file = data_file + '.' + label + '.encoded'
  open( enc_file, 'w') do |f|
    tree.encode( tokens, f)
  end

  #Decode and verify correctness
  data_enc_dec = nil
  open( tree_file, 'r') { |f| tree = Marshal.load( f.read) }
  open( enc_file, 'r') do |f|
    decoded_tokens = tree.decode( f)
    data_enc_dec = tokenizer.untokenize( decoded_tokens)
  end
  raise "#{label}: data was changed by encoding - decoding cycle!" if data != data_enc_dec

  #Statistics
  tree_size = File.size( tree_file)
  enc_size = File.size( enc_file)
  total_size = tree_size + enc_size

  puts "Encoded #{label} tokens:"
  puts "  Size of encoded data: #{enc_size.to_s.rjust(12)}"
  puts "  Tree size:            #{tree_size.to_s.rjust(12)}"
  puts "  ----------------------------------"
  puts "  Total size:           #{total_size.to_s.rjust(12)}"
  puts "  Original size:        #{data_size.to_s.rjust(12)}"
  compression = Integer( (data_size - total_size) * 100.0 / data_size)
  puts "  Compressed by:        #{compression.to_s.rjust(11)}%"
  puts "####################################"

end
