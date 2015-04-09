require 'test/unit'
require 'rubyquiz73'

# You must insert your email address as <youremail> in this method call!
DiGraph = RubyQuiz73.class_under_test("<youremail>")

class TestDiGraph < Test::Unit::TestCase
  def test_01_digraph_creation
    dg1 = DiGraph.new
    assert_kind_of(DiGraph, dg1)
    assert_equal(0, dg1.size)
  end
  
  def test_02_size
    dg2 = DiGraph.new([1,2], [2,3])
    assert_equal(3, dg2.size)
    assert_equal(2, dg2.num_edges)
  end
  
  # Add/write your own tests here...
end
