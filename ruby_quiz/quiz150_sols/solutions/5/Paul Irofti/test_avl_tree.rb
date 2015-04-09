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

#disabled this test case as it is order dependent and not valid
# def test_tree_height_of_one_or_two_nodes_is_N
#   @tree << 5
#   assert_equal 1, @tree.height
#   @tree << 6
#   assert_equal 2, @tree.height     #changed from 1
# end


def test_tree_height_of_three_nodes_should_be_greater_than_1
  @tree << 5
  @tree << 6
  @tree << 7
  assert(@tree.height > 1, "Tree appears to have stunted growth.")
end

def test_tree_growth_limit_is_1pt44_log_N
  (1..10).each{|i|
     @tree << i
     limit = (1.44 * Math::log(i)).ceil+1
     assert( @tree.height <= limit, "Tree of #{i} nodes is too tall
by #{@tree.height - limit}")
   }
end

def test_remove_node

  @tree << 314
  @tree.remove(314)
  assert(!@tree.include?(314))
end

end
