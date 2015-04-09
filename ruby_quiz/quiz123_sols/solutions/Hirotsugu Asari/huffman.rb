#! /usr/bin/env ruby

# Ruby Quiz #123
# Copyright 2007 Hirotsugu Asari

class String
  def huffman_encode
    a = self.split(//)
    h = {} # hash of character occurences
    a.each { |c|
      h[c] = h[c].nil? ? 1 : h[c] + 1
    }
    # puts h.inspect
    a = h.sort { |a,b|
      # sort the hash in descending order of the values
      b[1] <=> a[1]
    }
    a = a.transpose[0]
    
    encoding={}
    # for encoding, we will always start with
    # 0, 10, 110, 1110, 11110, ...
    a.each_with_index { |o,i|
      encoding[o] = ("1"*i).to_i(2) << 1
    }
    # .... and the last one is 111...111, which is obtained by
    # shifting 1111...1110 to the right by 1 bit.
    encoding[a[-1]] = encoding[a[-1]] << -1
    
    @key = encoding
    # puts @key.inspect
    
    # finally, map the binary representation of these numbers
    self.split(//).map { |c| encoding[c].to_s(2) }.
      # ...and concatenate
      inject("") { |s, i| s + i }
  end
  
  def huffman_key
    self.huffman_encode
    @key
  end

  def to_blocks_of_8( delim=" " )
    self.scan(%r{.{1,8}}).join(delim)
  end
  
end
