require 'test/unit'
require 'dictionary_matcher'

class DictionaryMatcherTest < Test::Unit::TestCase
 def setup
   @dictionary  = DictionaryMatcher.new
   @dictionary << "string"
   @dictionary << "Ruby"
 end

 def test_added_terms
   assert @dictionary.include?("Ruby")
   assert ! @dictionary.include?("missing")
   assert ! @dictionary.include?("stringing you along")
 end

 def test_regexp_like_seach
   assert_equal 5, @dictionary =~ "long string"
   assert_equal nil, @dictionary =~ "rub you the wrong way"
   assert_equal true, "long string" =~ @dictionary
 end

 def test_case_sesitive_match
   assert ! @dictionary.casefold?
   assert_not_equal 5, @dictionary =~ "lONg sTrINg"
   assert_not_equal true, "lonG STRing" =~ @dictionary
 end

 def test_case_insesitive_match
   @dictionary.instance_variable_set('@options', Regexp::IGNORECASE)

   assert @dictionary.casefold?
   assert_equal 5, @dictionary =~ "lONg sTrINg"
   assert_equal true, "lonG STRing" =~ @dictionary
 end

 def test_new_dictionary_matcher_with_options
   dictionary = DictionaryMatcher.new(%W( here be words ), Regexp::EXTENDED | Regexp::IGNORECASE, 'u')

   assert dictionary
   assert_equal %W( words be here ).sort, dictionary.sort
   assert_equal Regexp::EXTENDED | Regexp::IGNORECASE, dictionary.options
   assert_equal 'utf8', dictionary.kcode
 end

 def test_regexp_compatibility_methods
   assert @dictionary.eql?(@dictionary)
   assert ! @dictionary.casefold?
   assert @dictionary.kcode.nil?
   assert @dictionary.options.nil?
   assert_equal @dictionary.to_s, @dictionary.source
   assert_equal 'string|Ruby', @dictionary.source
   assert_equal '/string|Ruby/', @dictionary.inspect
 end
end
