class Regexp

  class NumericRegexpBuilder
    def initialize
      @patterns = []
    end

    def add_pattern( pattern )
      @patterns << pattern
    end

    alias :<< :add_pattern

    def to_regexp
      Regexp.new( "(?:^|[^-])\\b0*(?:" + @patterns.map{|p| "(?:#{p})"}.join( "|" ) + ")\\b" )
    end
  end

  def self.build( *parms )
    raise ArgumentError, "expected at least one parameter" if parms.empty?

    builder = NumericRegexpBuilder.new
    parms.each do |parm|
      case parm
        when Numeric
          builder << parm
        when Range
          parm.each { |i| builder << i }
        else
          raise ArgumentError,
            "unsupported parm type #{parm.class} (#{parm.inspect})"
      end
    end

    return builder.to_regexp
  end

end

if $0 == __FILE__
  require 'test/unit'

  class TC_Regexp < Test::Unit::TestCase

    def test_build_none
      assert_raise( ArgumentError ) do
        Regexp.build
      end
    end

    def test_build_one_integer
      re = Regexp.build( 5 )
      assert_match re, "5"
      assert_match re, "!5!"
      assert_match re, "!00005,"
      assert_no_match re, "15"
      assert_no_match re, "52"
    end

    def test_build_multiple_integers
      re = Regexp.build( 5, 7, 15 )
      assert_match re, "5"
      assert_match re, "!5!"
      assert_match re, "!00005,"
      assert_match re, "015"
      assert_match re, "007"
      assert_no_match re, "52"
      assert_no_match re, "57"
      assert_no_match re, "070"
    end

    def test_build_one_range
      re = Regexp.build( 0..100 )
      assert_match re, "000"
      assert_match re, "052"
      assert_match re, "15,32"
      assert_match re, "100"
      assert_no_match re, "777"
      assert_no_match re, "101"
    end

    def test_build_multiple_ranges
      re = Regexp.build( 0..10, 20...35, 71..77 )
      assert_match re, "000"
      assert_match re, "34"
      assert_match re, "000072"
      assert_no_match re, "11"
      assert_no_match re, "35"
    end

    def test_mix_and_match
      re = Regexp.build( 0, 5, 10..15, 17, 21, 31...35, 70...100 )
      assert_match re, "0"
      assert_match re, "005"
      assert_match re, "012"
      assert_no_match re, "22"
      assert_no_match re, "35"
      assert_no_match re, "100"
    end

    def test_negative
      re = Regexp.build( 0..5 )
      assert_no_match re, "-1"
      re = Regexp.build( -5..5 )
      assert_no_match re, "-1"
    end

  end
end
