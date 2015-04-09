$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'test/unit'
require 'dictionary_matcher'

class TestDictionaryMatcher < Test::Unit::TestCase
  
  @@dict = nil
  TEST_WORDS = %w{ aardvark abbe benign beni canker cankerworm grass can cann canna cannab cannabi cannabis }.freeze 
  
  def initialize(arg)
    super arg
  end
  
  def time_block(&block)
    start_time = Time.now
    block.call
    Time.now - start_time
  end
  
  def setup
    unless @@dict
      elapsed = time_block do
        @@dict = DictionaryMatcher.new
        IO.foreach("words_en.txt") do |line|
          @@dict << line.chomp
        end
      end
      #puts "Loaded dictionary in #{elapsed} seconds (#{@@dict.word_count} words)."
    end
  end
  
  def test_010_sanity
    expected_words = %w{ aardvark abbe benign canker cankerworm grass can canna cannabis }
    
    actual_words = []
    TEST_WORDS.each do |word|
      actual_words << word if @@dict.include?(word)
    end
    
    assert_equal(expected_words, actual_words)
  end
  
  def test_015_equal_tilde
    test_str = TEST_WORDS.join(' ')
    # Regexp-like substing search
    assert_equal(11, @@dict =~ "...........cankerworm")
    assert_nil(@@dict =~ "                     ")
    assert("...........cankerworm" =~ @@dict)
  end
  
  def test_020_long
    base_name = 'practical-file-system-design'
    test_str = IO.read("#{base_name}.txt").gsub("\n", " ")
    
    results = nil
    elapsed = time_block { results = @@dict.find_all_matching(test_str) }
    
    #    File.open("#{base_name}.results.txt", "w") do |f|
    #      results.each do |pos, len|
    #        f.puts "#{test_str[pos,len]} (#{pos},#{len})"
    #      end
    #    end
  end
  
  def test_030_find_all_matching
    expected_words = %w{ a r d ark abbe benign i canker cankerworm grass can n n canna n nab n nab i cannabis}
    actual_words = []
    test_str = TEST_WORDS.join(' ')
    elapsed = time_block { @@dict.find_all_matching(test_str) do |pos, len| actual_words << test_str[pos, len] end }
    assert_equal(expected_words, actual_words)
#    puts "Searched text in #{elapsed} seconds."
  end
  
end

require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.run(TestDictionaryMatcher)