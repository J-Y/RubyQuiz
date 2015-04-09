#!/usr/bin/env ruby -w

require "test/unit"

require "sxp"

class TestSXP < Test::Unit::TestCase
  def test_quiz_examples
    assert_equal([:max, [:count, :name]], sxp { max(count(:name)) })
    assert_equal([:count, 10], sxp { count(3 + 7) })
    assert_equal(8, sxp { 8 })
  end
  
  def test_normal_ruby_operations
    assert_raise(TypeError) { 7 / :field }
    assert_raise(NoMethodError) { 7 + count(:field) }
    assert_equal(11, 5 + 6)
    assert_raise(NoMethodError) { :field > 5 }
  end
end