require "test/unit"

require "wordloop"

class TestWordloop < Test::Unit::TestCase
  def setup
    @words_without_duplicate_letters = %w{ word ruby badger player }
    @words_with_duplicate_letters = %w{ Mississippi yummy Markham Dana wordloop }
    @words_that_do_not_loop = %w{ Dana sienna }
    @words_that_loop = %w{ Mississippi yummy Markham wordloop }
  end
  
  def test_initialize_without_word_parameter_should_raise_exception
    assert_raise(ArgumentError) { @wordloop = WordLoop.new }
  end
  
  def test_initialize_with_empty_string_should_raise_exception
    assert_raise(ArgumentError) { @wordloop = WordLoop.new("") }
  end
  
  def test_initialize_with_word_should_not_raise_exception
    @words_without_duplicate_letters.each do |word|
      assert_nothing_raised(Exception) { @wordloop = WordLoop.new(word) }
    end
  end
  
  def test_split_should_provide_word_as_array
    @words_without_duplicate_letters.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal(word.split(//), @wordloop.to_a)
    end
    
    @words_with_duplicate_letters.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal(word.split(//), @wordloop.to_a)
    end
  end
  
  def test_find_duplicate_letters_on_word_without_duplicates_should_return_empty_array
    @words_without_duplicate_letters.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal([], @wordloop.find_duplicate_letters)
    end
  end
  
  def test_word_without_duplicate_letters_should_return_false
    @words_without_duplicate_letters.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal(false, @wordloop.duplicate_letters?, "Working on #{word}...")
    end
  end
  
  def test_word_with_duplicate_letters_should_return_true
    @words_with_duplicate_letters.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal(true, @wordloop.duplicate_letters?, "Working on #{word}...")
    end
  end
  
  def test_words_without_loops_should_return_false
    @words_that_do_not_loop.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal(true, @wordloop.duplicate_letters?, "Working on #{word}...")
      assert_equal(false, @wordloop.has_loop?)
    end
  end
  
  def test_words_with_loops_should_return_true
    @words_that_loop.each do |word|
      @wordloop = WordLoop.new(word)
      assert_equal(true, @wordloop.duplicate_letters?, "Working on #{word}...")
      assert_equal(true, @wordloop.has_loop?)
    end
  end
  
  def test_words_with_loops_should_generate_correct_array
    yummy_sample = [
      ["y", "u"],
      ["m", "m"],
    ]
    
    @wordloop = WordLoop.new("yummy")
    assert_equal(true, @wordloop.duplicate_letters?)
    assert_equal(true, @wordloop.has_loop?)
    assert_equal(yummy_sample, @wordloop.generate_array)
    
    markham_sample = [
      ["m", "a"],
      ["a", "r"],
      ["h", "k"],
    ]
    
    @wordloop = WordLoop.new("markham")
    assert_equal(true, @wordloop.duplicate_letters?)
    assert_equal(true, @wordloop.has_loop?)
    assert_equal(markham_sample, @wordloop.generate_array)
    
    mississippi_sample = [
      [" ", "i", " "],
      [" ", "p", " "],
      [" ", "p", " "],
      ["M", "i", "s"],
      [" ", "s", "s"],
      [" ", "s", "i"],
    ]
    
    @wordloop = WordLoop.new("Mississippi")
    assert_equal(true, @wordloop.duplicate_letters?)
    assert_equal(true, @wordloop.has_loop?)
    assert_equal(mississippi_sample, @wordloop.generate_array)
  end
  
  def test_validate_final_output
    yummy_sample = <<END_YUMMY_OUTPUT
y u
m m
END_YUMMY_OUTPUT
    
    @wordloop = WordLoop.new("yummy")
    assert_equal(true, @wordloop.duplicate_letters?)
    assert_equal(true, @wordloop.has_loop?)
    assert_equal(yummy_sample, @wordloop.to_s)
    
    markham_sample = <<END_MARKHAM_OUTPUT
m a
a r
h k
END_MARKHAM_OUTPUT
    
    @wordloop = WordLoop.new("markham")
    assert_equal(true, @wordloop.duplicate_letters?)
    assert_equal(true, @wordloop.has_loop?)
    assert_equal(markham_sample, @wordloop.to_s)
    
    mississippi_sample = <<END_MISSISSIPPI_OUTPUT
  i  
  p  
  p  
M i s
  s s
  s i
END_MISSISSIPPI_OUTPUT
    
    @wordloop = WordLoop.new("Mississippi")
    assert_equal(true, @wordloop.duplicate_letters?)
    assert_equal(true, @wordloop.has_loop?)
    assert_equal(mississippi_sample, @wordloop.to_s)
  end
end