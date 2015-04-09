require 'test/unit'
require 'pangrams'

# Unit test harness to test the histogram and the frequency map code, and also to exercise the pangra
# generation code. The tests assume a list of posix words, one per line, in 'posix-words.txt'
class TestPangrams < Test::Unit::TestCase
  def test_histogram
    l = LetterHistogram.new ['moon']
    assert_equal false, l.pangram?
    assert_equal 1, l.repeats
    
    pangram = %w{the quick brown fox jumps over the lazy dog}
    l = LetterHistogram.new pangram
    assert_equal true, l.pangram?
    
    l = LetterHistogram.new ['qwertyuiopasdfghjklzxcvbn'] # m is missing
    m = l.missing_letters
    assert_equal 1, m.size
    assert_equal 'm', m.first
  end
     
  def test_random_search
    puts "-- Testing Random Pangram Generation --"
  
    p = Pangrams.from_file 'posix-words.txt'
    min_repeats_length = p.size
    min_repeats = 1000
    min_repeats_pangram = nil
    
    min_size = 160
    min_size_repeats = 1000
    min_size_pangram = nil
    
    count = 0
    
    p.random(1000) do |p, hist|
      repeats = hist.repeats
      size = p.size
      if repeats < min_repeats || repeats == min_repeats && size < min_repeats_length
        min_repeats_pangram = p
        min_repeats = repeats
        min_repeats_length = p.size 
        puts "New min-repeats pangram: #{min_repeats_pangram.join ' '} with #{min_repeats} repeats"
        $stdout.flush
      end
      if size < min_size || size == min_size && repeats < min_size_repeats
        min_size = size
        min_size_repeats = repeats
        min_size_pangram = p
        puts "New min-size pangram: #{min_size_pangram.join ' '} with #{min_size} words"
        $stdout.flush
      end
    end
  end
  
  def test_backtracking_search
    puts "--Testing backtracking search--"

    p = Pangrams.from_file 'posix-words.txt'
    min_repeats_length = p.size
    min_repeats = 1000
    min_repeats_pangram = nil
    
    min_size = 160
    min_size_repeats = 1000
    min_size_pangram = nil
        
    p.search(50) do |p, hist|
      repeats = hist.repeats
      size = p.size
      if repeats < min_repeats || repeats == min_repeats && size < min_repeats_length
        min_repeats_pangram = p
        min_repeats = repeats
        min_repeats_length = p.size 
        puts "New min-repeats pangram: #{min_repeats_pangram.join ' '} with #{min_repeats} repeats"
        $stdout.flush
      end
      if size < min_size || size == min_size && repeats < min_size_repeats
        min_size = size
        min_size_repeats = repeats
        min_size_pangram = p
        puts "New min-size pangram: #{min_size_pangram.join ' '} with #{min_size} words"
        $stdout.flush
      end
    end  
  end
end
