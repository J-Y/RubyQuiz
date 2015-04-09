require 'one_liner'
require 'test/unit'
require 'ostruct'

class TestOneLiner < Test::Unit::TestCase
  # Given a Numeric, provide a String representation with commas inserted
  # between each set of three digits in front of the decimal.  For example,
  # 1999995.99 should become "1,999,995.99".
  def test_commaize
    assert_equal "1,999,995.99011", OneLiner.commaize(1999995.99011)
  end
  
  # Given a nested Array of Arrays, perform a flatten()-like operation that
  # removes only the top level of nesting.  For example, [1, [2, [3]]] would
  # become [1, 2, [3]].
  def test_flatten_once
    ary = [1, [2, [3, 4]], [5]]
    flatter_ary = [1, 2, [3, 4], 5]
    assert_equal flatter_ary, OneLiner.flatten_once(ary)
  end
  
  # Shuffle the contents of a provided Array.
  def test_shuffle
    ary = [3,1,4,1,5,9]
    shuffled_ary = OneLiner.shuffle(ary)
    assert_not_equal ary, shuffled_ary
    assert_equal ary.sort, shuffled_ary.sort
  end
  
  # Given a Ruby class name in String form (like
  # "GhostWheel::Expression::LookAhead"), fetch the actual class object.
  def test_get_class
    assert_equal Test::Unit::TestCase,
                 OneLiner.get_class("Test::Unit::TestCase")
  end
  
  # Insert newlines into a paragraph of prose (provided in a String) so
  # lines will wrap at 40 characters.
  def test_wrap_text
    wrapped = "Insert newlines into a paragraph of " + "\n" + 
              "prose (provided in a String) so lines " + "\n" +
              "will wrap at 40 characters." + "\n"
    paragraph = "Insert newlines into a paragraph of " + 
                "prose (provided in a String) so lines " +
                "will wrap at 40 characters."
    assert_equal wrapped, OneLiner.wrap_text(paragraph)
  end
  
  # Given an Array of String words, build an Array of only those words that
  # are anagrams of the first word in the Array.
  def test_find_anagrams
    anagrams = %w(cat act)
    assert_equal anagrams, OneLiner.find_anagrams(%w(tac bat cat rat act))
  end
  
  
  # Convert a ThinkGeek t-shirt slogan (in String form) into a binary
  # representation (still a String).  For example, the popular shirt
  # "you are dumb" is actually printed as:
         # 111100111011111110101
         # 110000111100101100101
         # 1100100111010111011011100010
  def test_binarize
    output = "111100111011111110101" + "\n" +
             "110000111100101100101" + "\n" +
             "1100100111010111011011100010"
    assert_equal output, OneLiner.binarize("you are dumb")
  end
  
  # Provided with an open File object, select a random line of content.
  #
  # NOTE: This test assumes you're using File#read to get the string data
  #       from the file - if doing otherwise, update the test?
  def test_random_line
    file = OpenStruct.new(:read => "development:
  adapter: mysql
  database: redvase_development
  host: localhost
  username: root
  password:")
    lines = file.read.split("\n")
    line = OneLiner.random_line(file)
    assert_equal true, lines.include?(line)
  end
  
  # Given a wondrous number Integer, produce the sequence (in an Array).  A
  # wondrous number is a number that eventually reaches one, if you apply
  # the following rules to build a sequence from it.  If the current number
  # in the sequence is even, the next number is that number divided by two.
  # When the current number is odd, multiply that number by three and add
  # one to get the next number in the sequence.  Therefore, if we start with
  # the wondrous number 15, the sequence is [15, 46, 23, 70, 35, 106, 53,
  # 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1].
  def test_wondrous_sequence
    seq = [23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
    assert_equal seq, OneLiner.wondrous_sequence(23)
    assert_equal seq, OneLiner.wondrous_sequence_r(23)
  end
  
  # Convert an Array of objects to nested Hashes such that %w[one two three
  # four five] becomes {"one" => {"two" => {"three" => {"four" => "five"}}}}.
  def test_nested_hash
    hash = {:o => {:t => {:t => {:f => :f}}}}
    assert_equal hash, OneLiner.nested_hash([:o, :t, :t, :f, :f])
    assert_equal hash, OneLiner.nested_hash_r([:o, :t, :t, :f, :f])
  end
end

