# This is a solution submitted to Ruby Quiz #123:
#   http://www.rubyquiz.com/quiz123.html
#
# This solution has a number of features which might make it different
# to other solutions submitted.  It encodes to and decodes from actual
# binary data, not strings of "0" and "1" characters.  It is able to
# serialize and deserialize the Huffman encoder (which is a hash
# table, not a tree).  It uses a linear algorithm to create the
# Huffman code from the character frequency data.  And beyond that, it
# was written with an attempt to be efficient time-wise and
# memory-wise.  It uses an end-of-message token (:eom) to mark the end
# of the encoded message.  It therefore is able to handle messages
# that use 256 characters plus the 1 token.  It recognizes that with
# large messages some characters could be encoded with more than 8
# bits, and it handles those situations.  And finally it makes an
# attempt to recognize corrupt data, both in terms of the Huffman
# encoded message and the serialized encoder.
#
# Eric I.
# rubytraining at google-mail-domain (you know what it is!)


require 'stringio'


# Contains the functionality with which to calculate a Huffman code,
# encode a string and then decode back to the original string.  In
# addition it includes methods to serialize and deserialize the
# encoding/decoding map.
#
# Given a character/token fequency, creating a Huffman code takes
# linear time and uses the algorithm described in:
#
# {Huffman coding. (2007, May 9). In Wikipedia, The Free Encyclopedia.
# Retrieved 23:11, May 14, 2007, from
# http://en.wikipedia.org/w/index.php?title=Huffman_coding&oldid=129549124}[http://en.wikipedia.org/w/index.php?title=Huffman_coding&oldid=129549124]
module Huffman

  # A generic node from which LeafNode and InternalNode are derived.
  # Simply maintains a reference to a parent node and the (total)
  # frequency of this branch of the tree.
  class Node
    # The parent node.
    attr_accessor :parent

    # A number (integer or floating point) representing the frequency
    # of this node.  The only requirement is that when two frequencies
    # are combined, their combined frequency is the sum of the
    # component frequencies.
    attr_reader :frequency

    def initialize(frequency)
      @frequency = frequency
    end

    # Returns true if this node is the right child of its parent node.
    def am_right?
      @parent && @parent.right == self
    end

    # Returns the code for this node.  The code is an array of two
    # numbers.  The first element is the bit pattern used.  The second
    # element is the number of bits in the bit pattern that are
    # meaningful.  This is important given that leading 0's can be
    # significant.  This method works recursively, presumably starting
    # at a LeafNode and working up through InternalNodes.
    def code
      if @parent.nil?
        [0, 0]
      else
        parent = @parent.code

        # right nodes get an appended 1, left nodes an appended 0
        if am_right? : [(parent[0] << 1) + 1, parent[1] + 1]
        else           [parent[0] << 1      , parent[1] + 1]
        end
      end
    end
  end


  # Reprents a leaf node in the Huffman encoding tree.  Maintains the
  # token that this leaf node is used to encode.
  class LeafNode < Node
    attr_reader :token
    
    def initialize(token, frequency)
      super(frequency)
      @token = token
    end
  end


  # Represents an internal node in the Huffman encoding tree.
  # Maintains references to the left and right children nodes.
  class InternalNode < Node
    # Reference to the left or right child node.
    attr_reader :left, :right
    
    def initialize(left, right)
      super(left.frequency + right.frequency)
      @left, @right = left, right
      @left.parent = @right.parent = self
    end
  end


  # Represents a message encoded with a Huffman code.  This will
  # likely contain binary (i.e., non-ASCII) text.  It is built up
  # incrementally.
  class HuffmanString < String
    def initialize()
      super()
      @final_bit_pattern = @final_bit_count = 0
    end

    # Appends the bit pattern to the end of the string.  Only full
    # bytes are appended to the string.  Partial bytes are maintained
    # in @final_bit_pattern and @final_bit_count until more bits come
    # in or until the finish method is called.
    def append(bit_pattern, bit_count)
      while bit_count + @final_bit_count >= 8
        bits_needed = 8 - @final_bit_count  # bits needed to fill last byte
        bit_count -= bits_needed

        new_byte = ((@final_bit_pattern << bits_needed) |
                      (bit_pattern >> bit_count))
        self << new_byte

        @final_bit_pattern = @final_bit_count = 0
        bit_pattern &= ((1 << bit_count) - 1)
      end

      @final_bit_pattern =
        (@final_bit_pattern << bit_count) | bit_pattern
      
      @final_bit_count += bit_count
    end

    # Finish the string by appending any remaining bits, filling
    # remaining positions with 0's.
    def finish
      if @final_bit_count > 0
        self << (@final_bit_pattern << (8 - @final_bit_count))
        @final_bit_pattern = @final_bit_count = 0
      end
    end

    # Return a string that displays the bytes in the string displayed
    # as bit strings.
    def to_bit_string(per_line = 5)
      result = String.new

      on_line = 0  # number of bytes on the current line
      self.each_byte do |byte|
        if on_line >= per_line
          result << "\n"
          on_line = 0
        end
        result << ' ' if on_line > 0  # put space b/w bytes on line
        result << sprintf("%08b", byte)
        on_line += 1
      end

      result
    end
  end


  # This hash is used to encode strings with a Huffman code.  The
  # inverse of this hash can be used to decode back to the original
  # string.  The keys are the tokens to encode.  The corresponding
  # values are arrays of two numbers, the first of which is the bit
  # pattern and the second of which is the number of significant bits
  # in the bit pattern.  This bit count is necessary since leading 0's
  # can be significant.  Beyond the hash, this subclass of Hash has
  # methods to serialize and deserialize itself.
  class HuffmanEncoder < Hash

    # Serializes the Hash to a sequence of bytes.  The first byte is
    # the number of elements - 2 (note: the number of elements
    # includes the :eom (end of message) token).  Since there can be a
    # maximum of 257 symbols, by subtracting two we can store the size
    # in a single byte.  The next byte is the number of bits used to
    # encode the :eom token.  Then the next byte(s) contain the bit
    # pattern for the :eom token.  Following are groups of bytes for
    # each token in the following order: token (byte), encoded bit
    # count (byte), encode bit pattern [one or more bytes;
    # ((bit count - 1) / 8) bytes to be exact].
    def to_s
      raise "Invalid code" if size <= 1

      result = ''
      result << (size - 2)

      # generate keys but make sure :eom is the first in the list
      my_keys = keys
      my_keys.delete(:eom)
      my_keys.unshift(:eom)

      my_keys.each do |key|
        value = self[key]
        result << key unless key == :eom
        result << value[1]
        ((value[1] / 8.0).ceil - 1).downto(0) do |i|
          result << ((value[0] >> (8 * i)) & 0xFF)
        end
      end

      result
    end


    # Deserializes a string back into the encoding hash.  See
    # description of to_s to learn about the encoding format.
    def self.from_s(string)
      result = Hash.new

      io = StringIO.new(string)
      
      entry_count = io.readchar
      bit_count = io.readchar
      bits = 0
      ((bit_count - 1) / 8).downto(0) do |i|
        bits |= io.readchar << (8 * i)
      end
      result[:eom] = [bits, bit_count]

      (entry_count + 1).times do
        char = io.readchar
        bit_count = io.readchar
        bits = 0
        ((bit_count - 1) / 8).downto(0) do |i|
          bits |= io.readchar << (8 * i)
        end
        result[char] = [bits, bit_count]
      end

      raise "Serialized of Huffman encoder is corrupt." unless io.eof?

      result
    end
  end


  # Returns a HuffmanEncoder based on the character frequency data
  # passed in.  The frequency data can be passed in in one of two
  # forms:
  #   1) A hash in which the character/token maps to its frequency
  #   2) An array with elements that are themselves arrays of two
  #      elements; the first being the token, the second being the
  #      frequency.
  def self.generate(frequency_data)
    leaf_queue = []
    interior_queue = []

    # create leaf nodes from each token/frequency pair in data
    frequency_data.each do |datum|
      leaf_queue << LeafNode.new(*datum)
    end

    # sort queue by frequency
    leaf_queue = leaf_queue.sort_by { |leaf| leaf.frequency }

    # append the :eom token at start of queue
    leaf_queue.unshift( LeafNode.new(:eom, 0) )

    # save a copy of this queue, so we can easily access the leaves
    # later
    leaves = leaf_queue.dup

    # Loop until only one node is left in the queues; during each
    # iteration two nodes are removed from the queues and a new node
    # (whose children are the two nodes removed) is created added to
    # the interior queue.  Thus the number of nodes in the queues
    # decreases by one with each iteration.
    loop do
      node1 = dequeue_lowest(leaf_queue, interior_queue)
      node2 = dequeue_lowest(leaf_queue, interior_queue)
      break unless node2
      interior_queue.push(InternalNode.new(node2, node1))
    end

    # generate and return hash that maps tokens to codes
    leaves.inject(HuffmanEncoder.new) do |hash, leaf|
      hash[leaf.token] = leaf.code
      hash
    end
  end


  # Returns a frequency hash (mapping characters/tokens to their
  # occurence count) built from a string/message.
  def self.analyze(message)
    frequency_hash = Hash.new(0)
    0.upto(message.size - 1) do |i|
      frequency_hash[message[i, 1]] += 1
    end
    frequency_hash
  end


  # Encodes the provided message returning the encoded form and the
  # HuffmanEncoder which represents the mapping from tokens to bit
  # patterns.
  def self.encode(message)
    message_data = analyze(message)
    code_hash = generate(message_data)

    encoded_message = HuffmanString.new
    0.upto(message.size - 1) do |i|
      encoded_message.append(*code_hash[message[i, 1]])
    end
    encoded_message.append(*code_hash[:eom])
    encoded_message.finish
    [encoded_message, code_hash]
  end


  # Decodes the provided message using the HuffmanEncoder also
  # provided.
  def self.decode(message, huffman_encoder)
    decoded_message = ''

    huffman_decoder = huffman_encoder.invert
    max_bits =
      huffman_decoder.keys.map { |bits, bit_count| bit_count }.max

    done = false
    bit_pattern = bit_count = 0

    message.each_byte do |byte|
      # if we think we're done but there are more bytes, then we have
      # a problem
      raise "Encoded message is corrupt." if done

      # work through the byte bit by bit until we have a match to one
      # of the bit patterns in the decoder or until we have more bits
      # than are in any pattern in the decoder
      mask = 1 << 7
      until mask == 0
        bit = byte & mask > 0 ? 1 : 0
        bit_pattern = (bit_pattern << 1) + bit
        bit_count += 1
        key = [bit_pattern, bit_count]
        char = huffman_decoder[key]
        if char == :eom
          raise "Encoded message is corrupt." unless
            byte & (mask - 1) == 0
          done = true
          break  # leave until loop
        elsif char
          decoded_message << char
          bit_pattern = bit_count = 0
        end
        mask >>= 1
      end

      raise "Encoded message is corrupt." if bit_count > max_bits
    end
      
    decoded_message
  end

  
  protected
  
  # Takes two queues containing Nodes that are each sorted by
  # frequency (i.e., lowest frequencies precede higher frequencies).
  # Dequeues and returns the Node with the lower frequency.
  def self.dequeue_lowest(queue1, queue2)
    if queue1.empty?
      if queue2.empty? : nil
      else queue2.shift
      end
    else
      if queue2.empty?
        queue1.shift
      elsif queue1.first.frequency <= queue2.first.frequency
        queue1.shift
      else
        queue2.shift
      end
    end
  end
end


message = ARGV.join(' ')

encoded_message, coder = Huffman.encode(message)
coder_serialized = coder.to_s
coder_deserialized = Huffman::HuffmanEncoder.from_s(coder_serialized)
decoded_message = Huffman.decode(encoded_message, coder_deserialized)

puts "The original message:"
puts message

puts "\nThe encoded message:"
puts encoded_message.to_bit_string

puts "\nThe decoded message:"
puts decoded_message

puts "\nUsing ASCII encoding, the message occupies #{message.size} bytes."
puts "Using Huffman encoding, the message occupies #{encoded_message.size} bytes."
puts "Compression: #{(encoded_message.size * 100.0 / message.size).round}%"