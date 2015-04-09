#! /usr/bin/ruby

# Ruby Quiz #123
# Copyright 2007 Nicolas Modrzyk

class Huffman
 
  def encode string, tree=nil
    tree = create_encoding_tree string if tree==nil
    @tree = tree
    encoded = ""
    string.each_byte {|x| encoded << tree[x.chr].to_s}
    encoded
  end 

  def decode string, tree=nil
    tree = @tree if tree == nil
    decoding_tree = tree.invert  
    decoded = ""
    last_index = 0
    current_index = 1
    len = string.length
  
    while (current_index <= len) 
      s = string.slice(last_index,current_index-last_index)
      #puts ":"+s+":"+last_index.to_s+":"+current_index.to_s
      if decoding_tree.has_key?(s)
        decoded << decoding_tree[s] 
        last_index = current_index
        #p "GOAL:" + s+":"+decoding_tree[s]
      end
      current_index += 1
      
    end
  
    return decoded
    
  end

  def create_encoding_tree string
    tree = count_frequency string
  
    s = "1";
    count = 0;
  
    tree.keys.sort {|a,b| tree[a]<=>tree[b]}.reverse.each do |k|
      if count == 0
        tree[k] = "0"  
      elsif (count == (tree.keys.length-1))
        tree[k] = s + "1"
      else
        tree[k] = s + "0" 
        s << "1"
      end
      count += 1
    end
  
    return tree
  end

  private
  
  def count_frequency string
    hash = Hash.new
    string.each_byte {|x|
      if hash.key?(x.chr)
        hash[x.chr] = hash[x.chr].to_i + 1
      else
        hash[x.chr] = 1
      end
    }
    return hash
  end

  
end

def test string
  h = Huffman.new
  puts string
  encoded = h.encode string
  puts h.decode(encoded)
end


if $0 == __FILE__
  h = Huffman.new
  encoded = h.encode(ARGV.join)
  puts encoded
  #puts h.decode(encoded)
else
  puts "Entering test mode"
  #string = "ABRRKBAARAA"
  string2 = "I want this message to get encoded!"
  test string2
end
  
