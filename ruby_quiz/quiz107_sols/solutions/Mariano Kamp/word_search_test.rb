require 'test/unit'
require 'word_search'
class WordSearchTest < Test::Unit::TestCase
  def test_parse
    input = <<-INPUT
    XXXRXXX
    XXXUXXX
    XXXBXXX
    XXXYXXX
    
    RUBY
    INPUT
    
    word_search = WordSearch.new input
    assert_equal 1, word_search.words.size
    assert_equal 4, word_search.rows.size
    assert_equal 7, word_search.row_length
  end
  
  def test_multiple_words_and_case_insensitivity_of_words
    word_search = WordSearch.new <<-INPUT
    XXXXX
    
    one, TWO, ThrEe
    INPUT
    assert_equal ["one", "two", "three"], word_search.words
  end
  
  def test_unused_char
    input = <<-INPUT
    RUBY
    RUBY
    RUBY
      
    a
    INPUT
    begin
      WordSearch.new(input).solve
      fail
    rescue RuntimeError => e
      assert_equal "Word a not found", e.message
    end
  end
  
  def test_ruby_quiz
    input = <<-INPUT
    UEWRTRBHCD
    CXGZUWRYER
    ROCKSBAUCU
    SFKFMTYSGE
    YSOOUNMZIM
    TCGPRTIDAN
    HZGHQGWTUV
    HQMNDXZBST
    NTCLATNBCE
    YBURPZUXMS
    
    Ruby, rocks, DAN, matZ
    INPUT
   
    # If any word isn't found an exception will be raised
    WordSearch.new(input).solve
  end
  
  def test_snake
    input = <<-INPUT
    SxExxx
    xNxKxx
    xxAxxx
    
    Snake
    INPUT
    output = <<-OUTPUT
    S+E+++
    +N+K++
    ++A+++
    OUTPUT
    
    assert_equal output.gsub(' ',''), WordSearch.new(input).solve
  end
  
  def test_overflow
    input = []
    input << "BYRU\n"
    input << "YRUB\n"
    input << <<-INPUT
    U
    B
    Y
    R
    INPUT
    input << <<-INPUT
    xxxx
    xxRX
    xxxU
    Bxxx
    xYxx
    INPUT
    input << <<-INPUT
    Bxxxxx
    xYxxxx
    xxxxRx
    xxxxxU
    INPUT
    
    begin
      input.each do |tc_input|
        @tc_input = tc_input
        assert WordSearch.new(tc_input + "\nruby\n").solve
      end
    rescue
      puts "\n#{@tc_input} failed."
      fail
    end
  end
  
  def test_find
    input = <<-INPUT
    xxxRxxx
    xxxUxxx
    xxxBxxx
    xxxYxxx
    
    RUBY
    INPUT
    
    output = <<-OUTPUT
    +++R+++
    +++U+++
    +++B+++
    +++Y+++
    OUTPUT
    
    word_search = WordSearch.new input
    assert_equal output.gsub(/ /, ''), word_search.solve
  end

  def test_find_with_wildcard
    input = <<-INPUT
    xxxRxxx
    xxxUxxx
    xxxBxxx
    xxxYxxx
    
    R*BY
    INPUT
    
    assert WordSearch.new(input)
  end
  
  def test_neighbours
    word_search = WordSearch.new <<-INPUT
    ABCD
    EFGH
    IJKL
    MNOP
    
    foo, bar
    INPUT
    
    assert_equal "abc"+"eg"+"ijk", neighbour_values(word_search.field(1,1))
    assert_equal ("bd"+"efh"+"mnp").sort.join, neighbour_values(word_search.field(0,0))
  end
  
  
  private
  def neighbour_values(field)
    field.neighbours.collect{|f|f.value}.sort.join
  end
end
