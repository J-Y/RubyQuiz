# This is a dictionary matcher using a simple prefix tree
# implementation. It has all the additional gubbins, too, and is
# pretty quick when it comes to large input sets.
class DictionaryMatcher
  class MatchData
    def initialize(start_offset, end_offset, match, string)
      @start_offset, @end_offset, @match, @string = 
          start_offset, end_offset, match, string
      
      @offset = [start_offset, end_offset]
      @length = (end_offset - start_offset) + 1
    end

    attr_reader :start_offset, :end_offset, :match, :string, :offset, :length
      
    def pre_match
      @pre_match ||= @string[0...@start_offset]
    end

    def post_match
      @post_match ||= @string[(@end_offset + 1)..-1]
    end

    def char_count
      @char_count ||= @match.scan(/./mu).length
    end

    def to_s
      @match
    end
    
    def inspect
      "#<Match:#{@start_offset}: #{to_s.inspect}>"
    end

    def ==(o)
      if o.respond_to(:to_str)
        @match == o
      else
        super
      end
    end
  end

  class EnumerableMatcher
    include Enumerable
    
    def initialize(dm, str)
      @dm, @str = dm, str
    end

    def each
      str, ofs = @str, 0

      while md = @dm.match(str, ofs)
        yield md
        ofs = md.start_offset + md.length + 1 
      end

      self
    end
  end

  def initialize(*words)    
    @pt = {}
    words.each { |word| self << word }
  end

  def <<(word)
    # small memory optimization - if there's a longer word that shares
    # this prefix, we can discard it since we'll only ever take the 
    # shortest match anyway.
    word.split('').inject(@pt) do |pt, chr| 
      pt[chr] ||= {} 
    end.clear[:__WORD__] = true

    self
  end

  def include?(word)
    if md = self.match(word)
      md.match == word
    else
      false
    end
  end

  def to_enum(str)
    EnumerableMatcher.new(self, str)
  end

  def scan(str, &blk)
    if blk
      to_enum(str).each(&blk)
      str
    else
      a = []
      to_enum(str).each { |md| a << md.match }
      a
    end
  end
  
  def match(str, start_ofs = 0)
    start_ofs.upto(str.length) do |i|
      word = ""
      next_pt = @pt
      si = i
      while next_pt = next_pt[chr = str[i,1]]
        word << chr        
        return MatchData.new(si, i, word, str) if next_pt[:__WORD__]
        i+=1
      end
    end

    nil
  end

  def =~(str)
    m = match(str) and m.start_offset
  end
       
  def inspect
    @pt.inspect
  end
end

RossBamfordDictionaryMatcher = DictionaryMatcher

if $0 == __FILE__
  require 'test/unit'

  class TC_DM_01 < Test::Unit::TestCase
    def setup
      @dm = DictionaryMatcher.new
      
      @dm << "string"
      @dm << "Ruby"
    end
    
    def test_quiz_include?
      assert @dm.include?("Ruby")
      assert !@dm.include?("missing")
      assert !@dm.include?("stringing you along")
    end

    def test_quiz_matchop
      assert_equal 5, @dm =~ "long string"
      assert_nil @dm =~ "rub you the wrong way"
      
      assert_equal 5, @dm =~ "long Ruby string"
      assert_nil @dm =~ "long ruby str"

      assert_equal 5, 'long_string' =~ @dm
    end

    def test_match_data_01
      assert_nil @dm.match('rub you the wrong way')
    end

    def test_match_data_02
      assert_instance_of DictionaryMatcher::MatchData, md = @dm.match('long string')
      
      assert_equal 5, md.start_offset
      assert_equal 10, md.end_offset
      assert_equal [5,10], md.offset
      assert_equal "long ", md.pre_match
      assert_equal "string", md.match
      assert_equal "", md.post_match
    end
    
    def test_match_data_03
      assert_instance_of DictionaryMatcher::MatchData, md = @dm.match('long string too')
      
      assert_equal 5, md.start_offset
      assert_equal 10, md.end_offset
      assert_equal [5,10], md.offset
      assert_equal "long ", md.pre_match
      assert_equal "string", md.match
      assert_equal " too", md.post_match
    end
  end
  
  class TC_DM_02 < Test::Unit::TestCase
    def setup
      @dm = DictionaryMatcher.new
      
      @dm << "just"
      @dm << "dam"
      @dm << "damage"
    end

    def test_always_finds_first_match
      assert_instance_of DictionaryMatcher::MatchData, md = @dm.match('just damaged')
      
      assert_equal 0, md.start_offset
      assert_equal 3, md.end_offset
      assert_equal [0,3], md.offset
      assert_equal "", md.pre_match
      assert_equal "just", md.match
      assert_equal " damaged", md.post_match
    end
    
    def test_always_finds_shortest_match
      assert_instance_of DictionaryMatcher::MatchData, md = @dm.match('when damaged')
      
      assert_equal 5, md.start_offset
      assert_equal 7, md.end_offset
      assert_equal [5,7], md.offset
      assert_equal "when ", md.pre_match
      assert_equal "dam", md.match
      assert_equal "aged", md.post_match
    end

    def test_scan_01
      @dm << 'when'
      assert_equal ["when", "dam"], @dm.scan('do not open when damaged')
    end
    
    def test_scan_02
      @dm << 'when'
      a = []
      scanr = @dm.scan('do not open when damaged') { |md| a << md.match }
      assert_equal 'do not open when damaged', scanr
      assert_equal ["when", "dam"], a
    end
    
    def test_to_enum_01
      @dm << 'when'
      enum = @dm.to_enum('do not open when damaged')
      assert_equal ["when", "dam"], enum.inject([]) { |a,md| a << md.match }
      assert_equal ["when"], enum.select { |md| md.match =~ /^w/ }.map { |md| md.match }
      assert_equal ["dam"], enum.reject { |md| md.match =~ /^w/ }.map { |md| md.match }
    end    
  end

  class TC_DM_03 < Test::Unit::TestCase
    def setup
      @dm = DictionaryMatcher.new
      @dm << 'ヂ' 
      @dm << 'fro' 
      @dm << 'だ'
    end

    def test_unicode_aware_01
      assert_instance_of DictionaryMatcher::MatchData, 
          md = @dm.match('ヂ is')
      
      assert_equal 0, md.start_offset
      assert_equal 2, md.end_offset
      assert_equal [0,2], md.offset
      assert_equal 3, md.length
      assert_equal 1, md.char_count
      assert_equal "", md.pre_match
      assert_equal "ヂ", md.match
      assert_equal " is", md.post_match
    end

    def test_unicode_aware_02
      assert_instance_of DictionaryMatcher::MatchData,
        md = @dm.match(', だ is fr')
      
      assert_equal 2, md.start_offset
      assert_equal 4, md.end_offset
      assert_equal [2,4], md.offset
      assert_equal 3, md.length
      assert_equal 1, md.char_count
      assert_equal ", ", md.pre_match
      assert_equal "だ", md.match
      assert_equal " is fr", md.post_match
    end
    
    def test_unicode_aware_03
      a = []
      @dm.scan('ヂ is from Katakana, だ is from Hiragana') { |md| a << md.match }
      assert_equal ['ヂ','fro','だ', 'fro'], a
    end
  end
end
