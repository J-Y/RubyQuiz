require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'
require 'wordsearch'

class LetterGridTest < Test::Unit::TestCase
  def testLoading
    a = LetterGrid.new("HELLO")
    assert_equal(GridLetterSequence.new("HELLO"), a[0])
    
    a=LetterGrid.new("HELLO","GOODBYE")
    assert_equal(GridLetterSequence.new("HELLO"), a[0])
    assert_equal(GridLetterSequence.new("GOODBYE"), a[1])
  end
  
  def testSequencesSuperSimple
    a = LetterGrid.new("A")
    b = a.sequences
    assert_not_nil(b)
    assert_equal(3, b.length, "result was #{b}")
    assert(b.member?(GridLetterSequence.new("A")))
    assert(!b.member?(GridLetterSequence.new("AA")), "found AA")
  end
  
  def testSequencesOneByTwo
    a = LetterGrid.new("AB")
    b = a.sequences
    assert_not_nil(b)
    assert_equal(6, b.length, "result was #{b}")
    assert(b.member?(GridLetterSequence.new("AB")))
    assert(b.member?(GridLetterSequence.new("BA")))
    assert(b.member?(GridLetterSequence.new("A")))
    assert(b.member?(GridLetterSequence.new("B")))
  end
  
  def testRightDiags
    a = LetterGrid.new("AB", "CD")
    sequences = a.diag_right_sequences
    
    assert_not_nil(sequences)
    assert_equal(4, sequences.length, "result was #{sequences.inspect}")
    assert(sequences.member?(GridLetterSequence.new("AD")))
    assert(sequences.member?(GridLetterSequence.new("B")))
    assert(sequences.member?(GridLetterSequence.new("C")))
    assert(sequences.member?(GridLetterSequence.new("DA")))
  end
  
  def testLeftDiags
    a = LetterGrid.new("AB", "CD")
    sequences = a.diag_left_sequences
    assert_not_nil(sequences, "nothing came back")
    assert_equal(4, sequences.length, "result was #{sequences.inspect}")
    assert(sequences.member?(GridLetterSequence.new("A")))
    assert(sequences.member?(GridLetterSequence.new("D")))
    assert(sequences.member?(GridLetterSequence.new("BC")))
    assert(sequences.member?(GridLetterSequence.new("CB")))
  end
    
  def testRightDiagIndices32
    indices = right_diag(3,2)
    assert_equal(6, indices.length)
    assert_equal([[3,0]], indices[0])
    assert_equal([[2,0],[3,1]], indices[1])
    assert_equal([[1,0],[2,1],[3,2]], indices[2])
    assert_equal([[0,0],[1,1],[2,2]], indices[3])
    assert_equal([[0,1],[1,2]], indices[4])
    assert_equal([[0,2]], indices[5])
  end

  def testRightDiagIndices23
    indices = right_diag(2,3)
    assert_equal(6, indices.length)
    assert_equal([[2,0]], indices[0])
    assert_equal([[1,0],[2,1]], indices[1])
    assert_equal([[0,0],[1,1],[2,2]], indices[2])
    assert_equal([[0,1],[1,2],[2,3]], indices[3])
    assert_equal([[0,2],[1,3]], indices[4])
    assert_equal([[0,3]], indices[5])
  end
end

class GridLetterTest < Test::Unit::TestCase
  def testFound
    a = GridLetter.new("a")
    assert(!a.found, "wasn't initialized properly")
    a.found=true
    assert(a.found, "setter didn't work")
    a.found = false
    assert(!a.found, "setter didn't work")
  end
  
  def testEquals
    a = GridLetter.new("a")
    b = GridLetter.new("a")
    assert_equal(a,b)
    b.found = true
    assert_not_equal(a,b)
  end
  
end

class GridLetterSequenceTest < Test::Unit::TestCase
  def testStringEachFixnums
    a = GridLetterSequence.new("Hello World")
    a.each {|x| assert(!x.found, "#{x} wasn't found?")}
    a.each {|x| x.found=true }
    a.each {|x| assert(x.found)}
  end  

  def testFlyweightness
    a=GridLetterSequence.new("Hello Hank")
    a[0].found = true
    assert(!a[6].found, "flyweight. blah.")
  end
  
  def testReverse
    a = GridLetterSequence.new("Hello")
    assert_equal(GridLetterSequence.new("olleH"), a.reverse)
  end
  
  def testEquals
    assert(GridLetterSequence.new("AA") != GridLetterSequence.new("A"), "AA == A?")
    assert(GridLetterSequence.new("A") != GridLetterSequence.new("AA"), "A == AA?")
    assert(GridLetterSequence.new("AA") == GridLetterSequence.new("AA"), "AA != AA?")
    assert(GridLetterSequence.new("AA") != GridLetterSequence.new("AB"), "AA == AB?")
  end

  def testFindingEmbeddedStrings
    t = GridLetterSequence.new("DOGCATMAN")
    assert_equal([[4,4], [7,7]], t.find("A"))
    assert_equal([[3,5]], t.find("CAT"))
    assert_equal([[0,2]], t.find("DOG"))
    assert_equal([[6,8]], t.find("MAN"))
    assert_equal([], t.find("FLIBBER"))
  end
  
  def testMarkingFound
    t = GridLetterSequence.new("DOGCATMAN")
    t.markFound([[3,5], [8,8]])
    t[3..5].each{|x| assert(x.found)}
    t[8..8].each{|x| assert(x.found)}
    t[0..2].each{|x| assert(!x.found)}
    t[6..7].each{|x| assert(!x.found)}
  end
end


