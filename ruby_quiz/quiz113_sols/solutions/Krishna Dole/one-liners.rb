require 'test/unit'
# test setup mostly borrowed from Jamie Macey

class OneLiner
  class << self
    
    # this was the hardest one for me. this answer is not 
    # entirely my own, as it was inspired by 
    # http://rubyforge.org/snippet/detail.php?type=snippet&id=8
    # (which does not work for numbers like 0.234234234234)
    def commaize(quiz)
      quiz.to_s.sub(/^(-*)(\d+)/){|m| $1 + $2.gsub(/(\d)(?=\d{3}+$)/, '\1,')}
    end

    def flatten_once(quiz)
      quiz.inject([]){|n, e| e.is_a?(Array) ? n + e : n << e }
    end

    def shuffle(quiz)
      a = quiz.dup; Array.new(a.size).map{|i| a.delete_at(rand(a.size)) }
    end
    
    def get_class(quiz)
      require quiz.downcase.split("::")[0..-2].join("/"); eval quiz
    end

    def wrap_text(quiz)
      quiz.gsub(/(.{1,40}(\s|$))/, '\1' + "\n").chop
    end

    def find_anagrams(quiz)
      quiz.select{|w| w.scan(/./).sort == quiz[0].scan(/./).sort}
    end

    def binarize(quiz)
      s = ""; quiz.each_byte {|c| c == 32 ? s << "\n" : s << "%b" % c}; s
    end

    # using #readlines would be easiest, but unlike that, this solution
    # should work fine on files that are too big to hold in memory.
    # unfortunately, it is more than 80 chars when using a variable 
    # named 'quiz'
    def random_line(quiz)
      i = rand(quiz.each{|l|}.lineno); quiz.rewind; quiz.each{|l| return l if quiz.lineno == i+1}
    end

    # i know. it's 6 lines, not one. and more than 80 chars :(
    def wondrous_sequence(quiz)
      a = [n = quiz]; while n != 1; n = (n % 2 > 0 ? n * 3 + 1 : n / 2); a << n; end; a
    end

    # i guess it is cheating to use recursion (two lines)
    # but it worked too nicely to resist here.
    def nested_hash(quiz)
      quiz.size > 1 ? {quiz[0] => nested_hash(quiz[1..-1])} : quiz[0]
    end
  end
end

require 'tempfile'
class TestOneLiner < Test::Unit::TestCase
 # Given a Numeric, provide a String representation with commas inserted
 # between each set of three digits in front of the decimal.  For example,
 # 1999995.99 should become "1,999,995.99".
 def test_commaize
   assert_equal "995", OneLiner.commaize(995)
   assert_equal "1,995", OneLiner.commaize(1995)
   assert_equal "12,995", OneLiner.commaize(12995)
   assert_equal "123,995", OneLiner.commaize(123995)
   assert_equal "1,234,995", OneLiner.commaize(1234995)
   assert_equal "1,234,567,890,995", OneLiner.commaize(1234567890995)
   assert_equal "99,995.992349834", OneLiner.commaize(99995.992349834)
   assert_equal "0.992349834", OneLiner.commaize(0.992349834)
   assert_equal "-0.992349834", OneLiner.commaize(-0.992349834)
   assert_equal "999,995.99", OneLiner.commaize(999995.99)
   assert_equal "-1,999,995.99", OneLiner.commaize(-1999995.99)
 end

 # Given a nested Array of Arrays, perform a flatten()-like operation that
 # removes only the top level of nesting.  For example, [1, [2, [3]]] would
 # become [1, 2, [3]].
 def test_flatten_once
   ary = [1, [2, [3, 4]]]
   flatter_ary = [1, 2, [3, 4]]
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
             "will wrap at 40 characters."
   paragraph = "Insert newlines into a paragraph of " +
               "prose (provided in a String) so lines " +
               "will wrap at 40 characters."
   assert_equal wrapped, OneLiner.wrap_text(paragraph)
 end

 # Given an Array of String words, build an Array of only those words that
 # are anagrams of the first word in the Array.
 def test_find_anagrams
   anagrams = %w(tac cat act)
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
   f = Tempfile.new("foo")
   f.print("development:
 adapter: mysql
 database: redvase_development
 host: localhost
 username: root
 password:")
   f.flush
   f.rewind
   lines = f.readlines
   line = OneLiner.random_line(f)
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
 end

 # Convert an Array of objects to nested Hashes such that %w[one two three
 # four five] becomes {"one" => {"two" => {"three" => {"four" => "five"}}}}.
 def test_nested_hash
   hash = {:o => {:t => {:t => {:f => :f}}}}
   assert_equal hash, OneLiner.nested_hash([:o, :t, :t, :f, :f])
 end
end