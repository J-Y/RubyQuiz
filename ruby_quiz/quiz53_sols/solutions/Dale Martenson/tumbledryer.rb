require 'rubygems'
require_gem "usage"

class Huffman
   class LeafNode
       attr_accessor :type, :parent, :weight, :symbol
             def initialize( symbol, weight )
           @type = :leaf
           @parent = nil
           @symbol = symbol
           @weight = weight
       end
   end
     class InternalNode
       attr_accessor :type,:parent, :left_child, :right_child, :weight
             def initialize( node_left, node_right )
           @type = :internal
           @parent = nil
           @left_child = node_left
           @right_child = node_right
                     left_weight = (node_left != nil) ? node_left.weight : 0
           right_weight = (node_right != nil) ? node_right.weight : 0
                 @weight = left_weight + right_weight
                     @left_child.parent = self if @left_child != nil
           @right_child.parent = self if @right_child != nil
       end
   end

   attr_reader :root, :encode_table, :decode_table
     def initialize
       @root = nil
       @encode_table = {}
       @decode_table = {}
   end
     def encode( string )
       original_words = string.split(/ /)
       all_words = original_words.sort
         dictionary = Hash.new(0)
       all_words.each do |word|
           dictionary[ word ] += 1
       end
       sorted_dictionary = dictionary.sort {|a,b| a[1]<=>b[1]}
             generate_huffman_tree( sorted_dictionary )
       walk
             encoding = ""
       original_words.each do |word|
           encoding += @encode_table[ word ]
       end
             encoding
   end
     def generate_huffman_tree( dictionary )
       heap = []
       dictionary.each do |item|
           heap << LeafNode.new( item[0], item[1] )
       end
             heap.sort {|a,b| a.weight<=>b.weight}
             while heap.size > 1
           n1 = heap.shift
           n2 = heap.shift
           heap << InternalNode.new( n1, n2 )
           heap.sort {|a,b| a.weight<=>b.weight}
       end
       @root = heap.shift
   end
     def walk(node=@root, encoding='', level=0)
       if node != nil then
           if node.type == :leaf then
               # visit leaf
               # print "symbol:#{node.symbol} encoding:#{encoding} level:#{level}\n"
               @encode_table[ node.symbol ] = encoding
               @decode_table[ encoding ] = node.symbol
           else
               # must be internal
               walk( node.left_child, encoding+'0',level+1 )
               walk( node.right_child, encoding+'1',level+1 )
           end
       end
   end

   def decode( string )
       output = ''
       lookup = ''
       string.each_byte do |b|
           lookup << b.chr
           if @decode_table.has_key?( lookup ) then
               output += decode_table[ lookup ] + ' '
               lookup = ''
           end
       end
       output
   end
end

h = Huffman.new

Usage.new "<infile" do |usage|
  print <<EOT
# Undoes the work of TumbleDRYer.
class WashingMachine
  def initialize
EOT
     puts "      @encoding = '#{h.encode(usage.infile.read)}'"
   puts "      @decode_table = {"
   h.decode_table.each_pair { |k,v| puts "      '#{k}' => %q{#{v}}," }
   puts "    }"
         print <<EOT
  end
      def output
     lookup = ''
     @encoding.each_byte do |b|
        lookup << b.chr
        if @decode_table.has_key?( lookup ) then
           print @decode_table[ lookup ] + ' '
           lookup = ''
        end
     end
  end
end
  WashingMachine.new.output
EOT
end
