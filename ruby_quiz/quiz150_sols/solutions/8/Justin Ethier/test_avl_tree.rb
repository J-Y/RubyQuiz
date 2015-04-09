require "test/unit"
require "avl_tree.rb"

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
  assert_equal(ary.size, traversal.size)
  ary.each{|n| assert traversal.include?(n), "#{n} was not visited in tree."}
end

def test_balances_left
 4.downto(1){|i| @tree << i}
 assert(@tree.height<4)
end

def test_balances_right
 0.upto(4){|i| @tree << i}
 assert(@tree.height<4)
end

end