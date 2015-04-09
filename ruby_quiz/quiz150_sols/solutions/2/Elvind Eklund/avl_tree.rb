#!/usr/bin/env ruby -wKU

class AVLTree
 attr_accessor :head, :left
 def initialize
   @head = nil
   @left = nil
 end
 def empty?
   @head.nil?
 end
 def << (thing)
   if empty?
     @head = thing
   else
     @left = AVLTree.new
     @left << thing
   end
 end
 def include?(value)
   @head == value || (@left != nil && @left.include?(value))
 end
end

if $0 == __FILE__
 require "test/unit"

 class TestAVLTree < Test::Unit::TestCase
   def setup
     @tree = AVLTree.new
   end

   def test_tree_membership
     assert_equal(true, @tree.empty?)
     assert_equal(false, @tree.include?(3))

     @tree << 3

     assert_equal(false, @tree.empty?)
     assert_equal(true, @tree.include?(3))
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
       assert(false, @tree.include?(i))
       @tree << i
       0.upto(i) do |j|
         assert(true, @tree.include?(j))
       end
     end
   end
 end
end
