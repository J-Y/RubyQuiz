#!/usr/bin/env ruby -wKU

require "test/unit"
require "avl_tree"

class TestAVLTree < Test::Unit::TestCase
  def setup
    @tree = AVLTree.new
  end

  ##################################################
  # Membership tests
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

    assert(@tree.include?(4), "4 not in #{@tree}")
    assert(@tree.include?(3), "3 not in #{@tree}")
  end

  def test_tree_include_many
    0.upto(10) do |i|
      assert_equal(false, @tree.include?(i),
                   "Tree should not include #{i} yet.")
      @tree << i
      0.upto(i) do |j|
        assert_equal(true, @tree.include?(j),
                     "Tree should have 0..#{i},"+
                     " where's #{j}? ")
      end
    end
  end

  # This sits at the intersection of membership
  # and height tests.  We know one node has height 1,
  # and two nodes has height 2, so if we insert one
  # object twice and the height is 1, there must
  # only be one node in the tree.
  def test_tree_does_not_keep_duplicates
    @tree << 'a'
    @tree << 'a'
    assert_equal 1, @tree.height, "one node: #{@tree}"
  end

  ##################################################
  # Height tests
  def test_tree_height_of_one_or_two_nodes_is_N
    @tree << 5
    assert_equal 1, @tree.height, "one node: #{@tree}"
    @tree << 6
    assert_equal 2, @tree.height, "two nodes: #{@tree}"
  end

  def test_tree_height_of_three_nodes_is_two
    @tree << 5
    @tree << 6
    @tree << 7
    assert_equal 2, @tree.height, @tree.to_s
  end

  # RobB: The more precise limit given in [Knuth] is
  # used rather than that from [Wikipedia]
  def test_tree_growth_limit_is_1pt44_log_N
    (1..10).each do |i|
      @tree << i
      limit = ((1.4405 *
                Math::log(i+2.0)/Math::log(2.0)
                ) - 0.3277).ceil
      assert(@tree.height <= limit,
             "Tree of #{i} nodes is too tall by" +
             " #{@tree.height - limit}" +
             " #{@tree}")
    end
  end

  def test_balances_left
    4.downto(1) { |i| @tree << i }
    assert(@tree.height < 4,
           "expected tree height #{@tree.height} < 4")
  end

  def test_balances_right
    1.upto(4) { |i| @tree << i }
    assert(@tree.height < 4,
           "expected tree height #{@tree.height} < 4")
  end

  def test_non_sequential_insertion__part_1
    items = [ 1, 3, 2 ]
    items.each do |i|
      @tree << i
    end
    items.each do |i|
      assert_equal(true, @tree.include?(i),
                   "where is #{i}? ")
    end
  end

  def test_non_sequential_insertion__part_2
    items = [ 3, 1, 2 ]
    items.each do |i|
      @tree << i
    end
    items.each do |i|
      assert_equal(true, @tree.include?(i),
                   "where is #{i}? ")
    end
  end

  ##################################################
  # Access tests (getting data back out)

  # RobB: this tests too much at one time; I sorted ary.
  def test_tree_traverse
    ary = [ 3, 5, 17, 30, 42, 54, 1, 2 ].sort

    ary.each { |n| @tree << n }
    traversal = []
    @tree.each { |n| traversal << n }

    assert_equal(ary.size, traversal.size)

    ary.each do |n|
      assert_equal(true, traversal.include?(n),
                   "#{n} was not visited in tree.")
    end
  end

  def test_tree_find
    [1,2,3,4].each{|n| @tree<<n}
    assert_equal(1, @tree.find{|v|v>0} )
    assert_equal(2, @tree.find{|v|v%2==0} )
  end

  def test_sequential_access
    items = [ 50, 17, 72 ]
    items.each { |n| @tree << n }
    items.sort.each_with_index do |e,i|
      assert_equal(e, @tree[i],
                   "@tree[#{i}] should be like " +
                   "#{items.inspect}.sort[#{i}]")
    end
  end

  # [Knuth] p.473: "The problem of deletion can be solved
  # in O(log N) steps if we approach it correctly."
  def test_remove_node
    @tree << 314
    @tree.remove(314)
    assert_equal(false, @tree.include?(314),
                 '314 still in the tree')
  end


  ##################################################
  # Interface tests
  
  def test_custom_comparison_code
    rev_tree = AVLTree.new { |a, b| b <=> a }
    values   = [3, 2, 1]
    values.each { |v| rev_tree << v }
    rev_tree.each { |v| assert_equal(values.shift, v) }

    len_tree = AVLTree.new { |a, b| a.length <=> b.length }
    values   = %w[3 22 111]
    values.each { |v| len_tree << v }
    len_tree.each { |v| assert_equal(values.shift, v) }
  end

end
=begin
[Knuth] Knuth, Donald Ervin,
    The Art of Computer Programming, 2nd ed.
    Volume 3, Sorting and Searching,
    section 6.2.3 "Balanced Trees", pp. 458-478
[Wikipedia]
    AVL Tree, http://en.wikipedia.org/wiki/AVL_tree
=end
