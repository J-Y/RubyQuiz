#!/usr/bin/env ruby -wKU

class TreeNode

 attr_accessor :left, :right, :data, :parent

 def initialize obj
   @left=nil
   @right=nil
   @data=obj
   @parent=nil
 end

 def attach_left node
   @left = node
   node.parent = self
 end

 def attach_right node
   @right = node
   node.parent = self
 end

 def height
   max( (left.height rescue 0) , (right.height rescue 0) )+1
 end

 def max *args
   args.inject{|m,n| n>m ? n : m}
 end

 def << node
   left ? (right ? (left << node) : (attach_right node)) : (attach_left node)
 end

 def include? obj
   (@data == obj) ||
     (@left.include? obj rescue false) ||
     (@right.include? obj rescue false)
 end

 def length
   len = 1
   len += @left.length if left
   len += @right.length if right
 end

end

class AVLTree

def initialize
 @root = nil
end

def empty?
 ! @root
end

def include?(obj)
 (! empty?) && (@root.include? obj)
end

def <<(obj)
 if empty?
   @root = TreeNode.new obj
 else
   @root << TreeNode.new(obj)
 end
 self
end

def height
 empty? ? 0 : @root.height
end

end

if $0 == __FILE__
 require "test/unit"

 class TestAVLTree < Test::Unit::TestCase
   def setup
     @tree = AVLTree.new
   end


   def test_tree_membership
     assert_equal(true,  @tree.empty?)
     assert_equal(false, @tree.include?(3))

     @tree << 3

     assert_equal(false, @tree.empty?)
     assert_equal(true,  @tree.include?(3))
   end

   def test_tree_height_of_one_or_two_nodes_is_N
     @tree << 5
     assert_equal 1, @tree.height
     @tree << 6
     assert_equal 2, @tree.height     #changed from 1
   end


   def test_tree_insertion
     assert_equal(true, @tree.empty?)
     assert_equal(false, @tree.include?(3))
     assert_equal(false, @tree.include?(5))

     @tree << 3
     @tree << 5

     assert_equal(false, @tree.empty?)
     assert_equal(true, @tree.include?(5))
     assert_equal(true, @tree.include?(3))
   end

   def test_tree_include_many
     0.upto(10) do |i|
       assert(! @tree.include?(i), "Tree should not include #{i} yet.")
       @tree << i
       0.upto(i) do |j|
         assert( @tree.include?(j), "Tree should include #{j} already.")
       end
     end
   end

   def test_tree_traverse
     ary = [3,5,17,30,42,54,1,2]
     ary.each{|n| @tree << n}
     traversal = []
     @tree.each{|n| traversal << n}
     ary.each{|n| assert traversal.include?(n), "#{n} was not visited in tree."}
   end

 end
end
