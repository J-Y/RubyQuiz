#!/usr/local/bin/ruby
#
# Quoted Printable
#
# A response to Ruby Quiz of the Week #23 - Quoted Printable [ruby-talk:133379]
#
# Encodes and decodes data to and from (respectively) the Quoted-Printable
# Content-Transfer-Encoding defined in RFC 2045 section 6.7.
#
# It operates as a standard Unix filter, reading from files 
# listed on the command-line or STDIN and writing to STDOUT. 
# In normal operation, all text read is encoded in the quoted
# printable format.  However, it also supports a -d command-line
# option and when present, text is decoded from quoted printable
# instead.  Finally, a -x command-line option is understood, and
# when given, <, > and & are also encoded, for use with XML.
#
# It also works as a Ruby library, adding to_quoted_printable and
# from_quoted_printable methods to String.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 13 Mar 2005
#
# Last modified: 16 Mar 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.
#

module QuotedPrintable
  
  WHITESPACE = [?\t, ?\ ]
  WHITESPACE_REGEXP = /[\t ]/
  WHITESPACE_ESCAPED_REGEXP = /=09|=20/
  
  # bytes that do not need to be escaped
  PRINTABLES = ((?!..?~).to_a + WHITESPACE) - [?=]
  
  MAX_LINE_WIDTH = 76
  
  NEWLINE = "\r\n"
  
  # additional bytes to escape for safety in an EBCDIC document
  EBCDIC_EXCEPTIONS = %w' ! " # $ @ [ \ ] ^ ` { | } ~ '
  EBCDIC_PRINTABLES = PRINTABLES - EBCDIC_EXCEPTIONS
  # additional bytes to escape for safety in an XML document
  XML_EXCEPTIONS = %w' < > & '
  XML_PRINTABLES = PRINTABLES - XML_EXCEPTIONS
  
  constants.each do |constant|
    const_get(constant).freeze
  end
  
  
  # Encode self to the quoted-printable transfer encoding
  def to_quoted_printable(printables = QuotedPrintable::PRINTABLES)
    QuotedPrintable::encode_string(self, printables)
  end
  
  # Decode self from the quoted-printable transfer encoding
  def from_quoted_printable
    QuotedPrintable::decode_string(self)
  end
  
  
  # Functions that do quoted-printable encoding and decoding
  class << self
    
    # Return the quoted-printable escaped representation of the given byte
    # (byte must be a Fixnum between 0 and 255)
    def encode_byte(byte)
      '=' + sprintf('%.2X', byte)
    end
    
    # Return the byte corresponding to the given quoted-printable escape
    # sequence as a String. If it's not valid, return nil.
    def decode_sequence(escape_sequence)
      if /=[0-9a-fA-F]{2}/ =~ escape_sequence
        escape_sequence[1, 2].to_i(16).chr
      elsif escape_sequence == "=#{NEWLINE}"
        ''
      end
    end
    
    # Return the given string encoded as quoted-printable, including the
    # canonical \r\n line terminators.
    def encode_string(string, printables = PRINTABLES)
      string.map {|line| encode_line(line, printables) }.join
    end
    
    # Consider the given string quoted-printable encoded, and decode it,
    # including translating line terminators to the native default.
    def decode_string(string)
      result = string.dup
      # strip trailing unescaped whitespace
      result.gsub!(/[\t ]+(?=\r\n|$)/, '')
      # decode escape sequences
      result.gsub!(/(=[^=]{2})/) {decode_sequence($1) || $1}
      # set newlines to native
      result.gsub!(/#{NEWLINE}/, "\n")
      result
    end
    
    private
      
      # Return the given line encoded as quoted-printable, including the
      # canonical \r\n line terminator(s).
      def encode_line(line, printables = PRINTABLES)
        # escape non-printables
        result = ''
        line.chomp.each_byte do |byte|
          if printables.include?(byte)
            result << byte
          else
            result << encode_byte(byte)
          end
        end
        
        soft_break!(result)
        
        # escape whitespace at end of line
        if WHITESPACE.include? result[-1]
          result[-1] = encode_byte(result[-1])
          # soft-break last line if escaping whitespace made it too long
          soft_break!(result)
        end
        
        # terminate line
        result << '=' unless /#$/$/ =~ line
        result << NEWLINE
      end
      
      # Insert soft breaks into the given string so that no line is more
      # than +MAX_LINE_WIDTH+ characters long
      def soft_break!(string)
        # this loop is about 4x slower fast_soft_break!
        something_to_do = true
        while something_to_do
          # soft-break long lines
          (something_to_do =
            string.sub!(/(.{#{MAX_LINE_WIDTH - 1}})([^\r\n])(?=[^\r\n])/) \
            	        {"#$1=#{NEWLINE}#$2"}) and
          # fix where soft breaks break escape sequences
          string.sub!(/=(.?)=#{NEWLINE}(..?)/) {"=#{NEWLINE}=#$1#$2"}
        end
      end
      
      def fast_soft_break!(string)
        string.gsub!(/(.{#{MAX_LINE_WIDTH - 4}})([^\r\n])(?=[^\r\n])/) \
                    {"#$1=#{NEWLINE}#$2"} and
        string.gsub!(/=(.?)=#{NEWLINE}(..?)/) {"=#{NEWLINE}=#$1#$2"}
      end
  end
end


# Add quoted-printable conversions to String
class String
  include QuotedPrintable  # to_quoted_printable, from_quoted_printable
end


if __FILE__ == $0
  require 'optparse'
  
  # Look, James, I'm opt-parsing! :)
  decode_mode = false
  xml_mode = false
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} [OPTIONS]"
    opts.separator ''
    opts.separator 'Specific Options:'
    
    opts.on('-d', '--decode', 'Convert from quoted-printable to native') do
      decode_mode = true
    end
    
    opts.on('-x', '--xml', 'Quote XML special characters <, > and &',
                           '(ignored when decoding)') do
      xml_mode = true
    end
    
    opts.on('-h', '-?', '--help', 'Show this text') do
      puts opts
      exit
    end
    
    opts.separator 'The default mode encodes STDIN as quoted-printable.'
  end
  
  opts.parse! ARGV
  
  operation =
    if decode_mode
      [:from_quoted_printable]
    elsif xml_mode
      [:to_quoted_printable, QuotedPrintable::XML_PRINTABLES]
    else
      [:to_quoted_printable]
    end
  
  if decode_mode
    ARGF.binmode
  else
    STDOUT.binmode
  end
  
  ARGF.each { |line| print line.send(*operation) }
  
end

