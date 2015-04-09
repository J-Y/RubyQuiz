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


def test_tree_height_of_one_node_is_one

  @tree << 5
  assert_equal 1, @tree.height

end

def test_tree_height_of_two_or_three_nodes_is_two
  @tree << 5
  @tree << 6

  assert_equal 2, @tree.height
  @tree << 3
  assert_equal 2, @tree.height
end

def test_to_a_returns_items_in_order
  @tree << 5
  @tree << 6
  @tree << 3

  assert_equal [3, 5, 6], @tree.to_a
end

def test_tree_growth_limit_is_1pt44_log_N
  (1..10).each{|i|
     @tree << i
     limit = (1.44 * Math::log(i)).ceil+1
     assert( @tree.height <= limit, "Tree of #{i} nodes is too tall
by #{@tree.height - limit}")
   }
 end

 def test_tree_balance_factor
   @tree << 4
   assert(@tree.balance_factor == 0)
   @tree << 5
   assert(@tree.balance_factor == 1)
   @tree << 6
   assert(@tree.balance_factor == 2)
 end

end
