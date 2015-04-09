require 'seq'
require 'test/unit'

class CommonSeq
 attr_reader :suffix_list
end

class TestSeq < Test::Unit::TestCase

 def test_basic_suffix_creation
   cs = CommonSeq.new("banana")
   assert_equal(%w{a ana anana banana na nana}, cs.suffix_list)
 end

 def test_empty
   cs = CommonSeq.new("")
   assert_nil cs.find_substrings
 end

 def test_length_one
   cs = CommonSeq.new("a")
   assert_nil cs.find_substrings
 end

 def test_length_two_no_match
   cs = CommonSeq.new("ab")
   assert_nil cs.find_substrings
 end

 def test_length_two_with_match
   cs = CommonSeq.new("aa")
   assert_equal [ 1, "a"],  cs.find_substrings
 end

 def test_length_three_no_match
   cs = CommonSeq.new("abc")
   assert_nil cs.find_substrings
 end

 def test_length_three_adjacent_match
   cs = CommonSeq.new("aab")
   assert_equal [ 1, "a"],  cs.find_substrings
 end

 def test_length_three_separated_match
   cs = CommonSeq.new("aba")
   assert_equal [ 1, "a"],  cs.find_substrings
 end

 def test_does_not_find_overlapping_match_length_one
   cs = CommonSeq.new("aaa")
   assert_equal [ 1, "a"],  cs.find_substrings
 end

 def test_does_not_find_overlapping_match_length_three
   cs = CommonSeq.new("aaaa")
   assert_equal [ 2, "aa"],  cs.find_substrings
 end

 def test_does_not_find_overlapping_match_length_two
   cs = CommonSeq.new("ababa")
   assert_equal [ 2, "ab"],  cs.find_substrings
 end

 def test_banana
   cs = CommonSeq.new("banana")
   assert_equal [ 2, "an"],  cs.find_substrings
 end
end
