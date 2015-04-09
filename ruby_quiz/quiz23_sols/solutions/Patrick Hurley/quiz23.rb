#
# == Synopsis
#
# Ruby Quiz #23
#
# The quoted printable encoding is used in primarily in email, thought it has
# recently seen some use in XML areas as well. The encoding is simple to
# translate to and from.
#
# This week's quiz is to build a filter that handles quoted printable
# translation.
#
# Your script should be a standard Unix filter, reading from files listed on
# the command-line or STDIN and writing to STDOUT. In normal operation, the
# script should encode all text read in the quoted printable format. However,
# your script should also support a -d command-line option and when present,
# text should be decoded from quoted printable instead. Finally, your script
# should understand a -x command-line option and when given, it should encode
# <, > and & for use with XML.
#
# == Usage
#
#    ruby quiz23.rb [-d | --decode ] [ -x | --xml ]
#
# == Author
# Patrick Hurley, Cornell-Mayo Assoc
#
# == Copyright
# Copytright (c) 2005 Cornell-Mayo Assoc
# Licensed under the same terms as Ruby.
#

require 'optparse'
require 'rdoc/usage'

module QuotedPrintable
  MAX_LINE_PRINTABLE_ENCODE_LENGTH = 76

  def from_qp
    result = self.gsub(/=\r\n/, "")
    result.gsub!(/\s*\r\n/m, $/)
    result.gsub!(/=([\dA-F]{2})/) { $1.hex.chr }
    result
  end

  def to_qp(handle_xml = false)
    char_mask = if (handle_xml)
                  /[\x00-\x08\x0b-\x1f\x7f-\xff=<>&]/
                else
                  /[\x00-\x08\x0b-\x1f\x7f-\xff=]/
                end

    # encode the non-space characters
    result = self.gsub(char_mask)  { |ch| "=%02X" % ch[0] }
    # encode the last space character at end of line
    result.gsub!(/(\s)(?=#{$/})/o) { |ch| "=%02X" % ch[0] }

    lines = result.scan(/
      # Match one of the three following cases
      (?:
    	# This will match the special case of an escape that would generally have
        # split across line boundries
        (?:  [^\n]{74}(?==[\dA-F]{2})  ) |
    	# This will match the case of a line of text that does not need to split
        (?:  [^\n]{0,76}(?=\n)  ) |
    	# This will match the case of a line of text that needs to be split without special adjustment
        (?:[^\n]{1,75}(?!\n{2}))
      )
      # Match zero or more newlines
      (?-x:#{$/}*)/x);
    lines.join("=\n").gsub(/#{$/}/m, "\r\n")
  end

  def QuotedPrintable.encode(handle_xml=false)
    STDOUT.binmode
    while (line = gets) do
      print line.to_qp(handle_xml)
    end
  end

  def QuotedPrintable.decode
    STDIN.binmode
    while (line = gets) do
      # I am a ruby newbie, and I could
      # not get gets to get the \r\n pairs
      # no matter how I set $/ - any pointers?
      line = line.chomp + "\r\n"
      print line.from_qp
    end
  end

end

class String
  include QuotedPrintable
end

if __FILE__ == $0

  decode = false
  handle_xml = true
  opts = OptionParser.new
  opts.on("-h", "--help")   { RDoc::usage; }
  opts.on("-d", "--decode") { decode = true }
  opts.on("-x", "--xml")    { handle_xml = true }

  opts.parse!(ARGV) rescue RDoc::usage('usage')

  if (decode)
    QuotedPrintable.decode()
  else
    QuotedPrintable.encode(handle_xml)
  end
end
