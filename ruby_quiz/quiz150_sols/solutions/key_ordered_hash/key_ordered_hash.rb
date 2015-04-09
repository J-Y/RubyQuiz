#!/usr/bin/env ruby -wKU

require "avl_tree"

class KeyOrderedHash
  Pair = Struct.new(:key, :value) do
    def <=>(other)
      key <=> other.key
    end
  end
  
  include Enumerable
  
  def initialize
    @pairs = AVLTree.new
  end
  
  def [](key)
    @pairs[Pair.new(key)].value
  end
  
  def []=(key, value)
    @pairs << Pair.new(key, value)
  end
  
  def each
    @pairs.each { |pair| yield pair.to_a }
  end
end

if __FILE__ == $PROGRAM_NAME
  require "pp"
  
  names = KeyOrderedHash.new
  %w[Rob\ Biedenharn Adam\ Shelly James\ Koppel].each_with_index do |name, i|
    names[name] = i
  end
  pp names.to_a
  # >> [["Adam Shelly", 1], ["James Koppel", 2], ["Rob Biedenharn", 0]]
end
