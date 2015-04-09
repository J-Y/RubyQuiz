#!/usr/bin/env ruby -wKU

require "test/unit"

require "avl_tree"

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

 def test_tree_should_allow_more_than_one_element
   @tree << 3
   @tree << 4

   assert(@tree.include?(4))
   assert(@tree.include?(3))
 end

 def test_tree_height_of_one_or_two_nodes_is_one
   @tree << 5
   assert_equal 1, @tree.height
   @tree << 6
   assert_equal 1, @tree.height
 end

 def test_tree_height_of_three_nodes_should_be_greater_than_1
   @tree << 5
   @tree << 6
   @tree << 7
   assert(@tree.height > 1, "Tree appears to have stunted growth.")
 end
end
