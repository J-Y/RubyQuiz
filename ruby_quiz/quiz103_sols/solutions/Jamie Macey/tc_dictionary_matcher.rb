class DictionaryMatcherTest < Test::Unit::TestCase
 def test_acceptance
   # creates a new empty matcher
   dm=DictionaryMatcher.new

   # adds strings to the matcher
   dm << "string"
   dm << "Ruby"

   # determines whether a given word was one of those added to the matcher
   assert_equal true,  dm.include?("Ruby")                 # => true
   assert_equal false, dm.include?("missing")              # => false
   assert_equal false, dm.include?("stringing you along")  # => false

   # Regexp-like substing search
   assert_equal 5,   dm =~ "long string"            # => 5
   assert_equal nil, dm =~ "rub you the wrong way"  # => nil

   # will automatically work as a result of implementing
   # DictionaryMatcher#=~ (see String#=~)
   assert_equal 5, "long string" =~ dm  # => true
 end

 def test_include_eh
   dm = DictionaryMatcher.new(['string', 'ruby', 'foo'])
   assert_equal true,  dm.include?('string' )
   assert_equal true,  dm.include?('ruby'   )
   assert_equal true,  dm.include?('foo'    )
   assert_equal false, dm.include?('stringa')
   assert_equal false, dm.include?('astring')
 end

 def test_equals_tilde
   dm = DictionaryMatcher.new(['string', 'ruby', 'foo'])
   assert_equal 0,   dm =~ 'string'
   assert_equal 0,   dm =~ 'string two'
   assert_equal 6,   dm =~ 'three string'
   assert_equal 5,   dm =~ 'four string five'
   assert_equal nil, dm =~ 'strng'

   assert_equal 0,  'string' =~ dm
   assert_equal 2,  'a string b' =~ dm
   assert_equal nil, 'strng' =~ dm
 end

 def test_case_sensitivity
   dm = DictionaryMatcher.new(['Foo','bar'])
   assert_equal 0,   dm =~ 'Foo'
   assert_equal 0,   dm =~ 'bar'
   assert_equal nil, dm =~ 'foo'
   assert_equal nil, dm =~ 'Bar'
 end

 def test_case_insensitivity
   dm = DictionaryMatcher.new(['Foo','bar'], true)
   assert_equal 0,   dm =~ 'Foo'
   assert_equal 0,   dm =~ 'bar'
   assert_equal 0,   dm =~ 'foo'
   assert_equal 0,   dm =~ 'Bar'
 end

 def test_greediness
   dm = DictionaryMatcher.new(['hi','child'])
   r = /hi|child/
   assert_equal r =~ 'children', dm =~ 'children'

   dm = DictionaryMatcher.new(['child','hi'])
   r = /child|hi/
   assert_equal r =~ 'children', dm =~ 'children'
 end

end

