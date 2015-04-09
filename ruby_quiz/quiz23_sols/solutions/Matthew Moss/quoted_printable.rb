#!/usr/bin/env ruby
#
# TODO:
#   - Limit lines to LINE_MAX_LENGTH during encoding.

require 'optparse'

# Global constants
XML_ENTITIES      = %w(< > &)
LINE_END_PAIR     = "\r\n"
LINE_CONTINUATION = "=\r\n"
LINE_MAX_LENGTH   = 76

class String
    def qp_decode()
        result = ''
        # output portions of line, alternating normal text and encoded bytes
        left = 0
        while right = index('=', left) do
            result << slice(left ... right) # if right > left
            result << qp_decode_byte( slice(right, 3) )
            left = right + 3
        end
        # add remainder of line
        result << slice(left .. -1) if slice(left)
        # finished
        result
    end

    def qp_encode(handleXmlEntities)
        # preserve trailing whitespace for later
        trimmed  = rstrip
        trail_ws = slice(trimmed.length .. -1)
        # encode characters on line
        result = ''
        trimmed.each_byte do |c|
            if handleXmlEntities and XML_ENTITIES.include?(c.chr)
                result << qp_encode_byte(c)
            else
                case c
                when 9, 32..60, 62..126
                    result << c
                else
                    result << qp_encode_byte(c)
                end
            end
        end
        # append trailing whitespace
        trail_ws.each_byte { |c| result << qp_encode_byte(c) }
        # finished
        result
    end

    def qp_decode_byte(s)
        s[1..-1].to_i(16)
    end

    def qp_encode_byte(c)
        '=' + (c < 10 ? '0' : '') + c.to_s(16).upcase
    end

    private :qp_decode_byte, :qp_encode_byte
end


class IO
    def qp_decode
        each_line { |line| $stdout.puts line.chomp.qp_decode }  # outputs native eol
    end

    def qp_encode(xmlEncode)
        each_line { |line| $stdout << line.chomp.qp_encode(xmlEncode) << LINE_END_PAIR }
    end
end

class QuotedPrintable
    def process(file)
        @decode ? file.qp_decode : file.qp_encode(@xmlEncode)
    end
    attr_writer :decode, :xmlEncode
end

# Main code from here down...
qp = QuotedPrintable.new

# Option Processing
opts = OptionParser.new
opts.on('-x') { qp.xmlEncode = true }
opts.on('-d') { qp.decode = true }
files = opts.parse(ARGV)

# File Processing
files.collect! { |f| File.new(f) }
files = [$stdin] if files.empty?
files.each { |f| qp.process(f) }
