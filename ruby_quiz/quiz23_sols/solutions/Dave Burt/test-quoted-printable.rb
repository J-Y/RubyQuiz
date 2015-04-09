require 'test/unit'

require ARGV.first || 'quoted-printable'

class TC_QuotedPrintable < Test::Unit::TestCase
  test_strings = [
    ["0 these  1lines are2 to count3 and test4 newline 5 endings 6         7\n",
     "0 these  1lines are2 to count3 and test4 newline 5 endings 6         7\r\n"],
    ["1234567890123456789012345678901234567890123456789012345678901234567890123456\n",
     "1234567890123456789012345678901234567890123456789012345678901234567890123456\r\n"],
    ["This should pass through unchanged:     [\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n",
     "This should pass through unchanged:     [\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\r\n"],
    ["And this too:      !\"\#$%&'()*+,-./0123456789:;<>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\n",
     "And this too:      !\"\#$%&'()*+,-./0123456789:;<>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\r\n",],
    ["This needs the = characters quoted;       TrueClass === (a == b)\n",
     "This needs the =3D characters quoted;       TrueClass =3D=3D=3D (a =3D=3D b)\r\n"],
    ["This is a long line and needs to be split between 'foo' and ' bar'. And foo bar.\n",
     "This is a long line and needs to be split between 'foo' and ' bar'. And foo=\r\n bar.\r\n",],
    ["This is a long line and needs to be split between 'foo ' and 'bar'. To foo bar.\n",
     "This is a long line and needs to be split between 'foo ' and 'bar'. To foo =\r\nbar.\r\n"],
    ["This line has escaped trailing white-space, but should not be wrapped...\t \n",
     "This line has escaped trailing white-space, but should not be wrapped...\t=20\r\n"],
    ["This wouldn't be a long line, except it's trailing white-space expands...\t \n",
     "This wouldn't be a long line, except it's trailing white-space expands...\t=\r\n=20\r\n"],
    ["This is to test that escape sequences are not chopped when wrapping.===\n",
     "This is to test that escape sequences are not chopped when wrapping.=3D=3D=\r\n=3D\r\n"],
    ["This is to test that escape sequences are not chopped when wrapping.===check that pushing half that escape sequence doesn't make this line too long\n",
     "This is to test that escape sequences are not chopped when wrapping.=3D=3D=\r\n=3Dcheck that pushing half that escape sequence doesn't make this line too =\r\nlong\r\n"],
    ["And here's one with no newline at the end",
     "And here's one with no newline at the end=\r\n"],
    ["===                                                                                   \n",
     "=3D=3D=3D                                                                  =\r\n                =20\r\n"],
  ]
  
  test_strings.each_with_index do |a, i|
    eval <<-END
      def test_encode_#{i}
        assert_equal(#{a.last.inspect}, #{a.first.inspect}.to_quoted_printable)
      end
      def test_decode_#{i}
        assert_equal(#{a.first.inspect}, #{a.last.inspect}.from_quoted_printable)
      end
    END
  end
  
  def test_random
    s = Array.new(10000) {(rand * 255).to_i.chr}.join
    encoded = s.to_quoted_printable
    decoded = encoded.from_quoted_printable
    assert(s != encoded, "encoding modified original string")
    assert(encoded != decoded, "decoding modified original string")
    assert(/^[!-~\r\n]+$/ =~ encoded, "contains illegal characters")
    assert_equal(s, decoded, "didn't correctly reverse")
    assert(!(/[^\r\n]{77}/ =~ encoded), "too wide")
  end
  
  def test_decode_strip_trailing_space
    assert_equal(
      "The following whitespace must be ignored:\n",
      "The following whitespace must be ignored:  	 \r\n".from_quoted_printable)
    assert_equal(
      "The following whitespace must be ignored:",
      "The following whitespace must be ignored:  	 ".from_quoted_printable)
  end
end

if __FILE__ == $0
   require 'test/unit/ui/console/testrunner'
   Test::Unit::UI::Console::TestRunner.run(TC_QuotedPrintable)
end