#!/usr/bin/ruby

# Operations on whiteout files. That is encoding and decoding.
module WhiteOutFileActions

  # Encode a whiteout file inplace. Optional compression can be used.
  def encode_file(encoder, infile, compression = true)
    head, tail = File.read(infile).split("\n", 2)
    if /^#!/ =~ head
      head = head + "\n" + 'require "whiteout"'
    else
      tail = head + "\n" + tail
      head = 'require "whiteout"'
    end
    File.open(infile + '.ws.rb', 'w') do | outfile |
      outfile.write head
      if compression
	outfile.write encoder::HEADER_COMPRESSED
	outfile.write encoder.encode_compressed(tail) 
      else
	outfile.write encoder::HEADER
	outfile.write encoder.encode(tail) 
      end
      FileUtils.mv(infile + '.ws.rb', infile)
    end
  end

  # Decode a whiteout file. Returns the code after the require "whiteout"
  def decode_file(encoders, filename)
    code = File.read(filename).gsub(/^.*require\s*['"]whiteout['"]/m, '')
    encoders.each do | mod |    
      if mod::HEADER == code[0,mod::HEADER.length]
	return mod.decode(code[mod::HEADER.length..-1])
      end
      if mod::HEADER_COMPRESSED == code[0,mod::HEADER_COMPRESSED.length]
	return mod.decode_compressed(code[mod::HEADER_COMPRESSED.length..-1])
      end
    end
    throw "No matching decompression module found"
  end

  extend self
end

# Mixin providing compressed encoding to modules that have encode and decode.
module CompressedEncoding  
  require 'zlib'

  # Compress a string and then encode it to whitespace
  def encode_compressed(string)
    self.encode(Zlib::Deflate.deflate(string))
  end

  # Decode a whitespace encoded string and then decompress it.
  def decode_compressed(string)
    Zlib::Inflate.inflate(self.decode(string))
  end

  extend self
end

# Short uncompressed version
# We code each byte into a ' ' or \n.
# Encoding, decoding are one-liners.
module WhiteOutSimple
  include CompressedEncoding

  HEADER            = "  \t\t"
  HEADER_COMPRESSED = " \t \t"

  # Encode a string into whitespace
  def encode(string)
    string.unpack('B*')[0].tr('01', " \n")
  end

  # Decode a whitespace encoded string
  def decode(string)
    [string.tr(" \n", '01')].pack('B*')
  end

  extend self
end

# Compact version with the added ability to do zlib compression.
# We code each byte into four bytes of " ", \t, \n, \r.
module WhiteOutCompact
  include CompressedEncoding

  HEADER            = " \t\n\r"
  HEADER_COMPRESSED = "\r\n\t "
  WHITESPACE = [" ", "\t", "\n", "\r", "\002", "\003", "\013", "\000"].uniq

  # Encode a string into eight different whitespace characters.
  def encode(string, symbols = WHITESPACE)
    bits_per_symbol = (Math.log(symbols.length) / Math.log(2)).floor
    result = ''
    reg = %r{#{'.?' * bits_per_symbol}}
    string.unpack('B*')[0].scan(reg) do | bits |
      result << symbols[bits.to_i(2)]
    end
    result
  end

  # Decode a string from whitespace.
  def decode(string, symbols = WHITESPACE)    
    bits_per_symbol = (Math.log(symbols.length) / Math.log(2)).floor
    bitstring = ''
    string.each_byte do | b |
      bitstring << "%0*b" % [bits_per_symbol, symbols.index(b.chr)]
    end
    [bitstring].pack('B*')
  end

  extend self
end

module WhiteOutFileActions
  ENCODERS = [WhiteOutCompact, WhiteOutSimple]
end
# The additional '-c' switch yields smaller files but uses symbols that may or may not be interpreted as whitespace by your viewer.
#
# Usage:
#   whiteout.rb [OPTIONS] FILE1 [FILES...]
if __FILE__ == $0
  require 'fileutils'

  # Encoding

  require 'optparse'

  # Options for the whiteout program
  class WhiteOutOptions < OptionParser
    attr_accessor :encoding
    attr_accessor :compression
    attr_accessor :action

    def initialize(args = ARGV)
      super(args)

      self.encoding = WhiteOutSimple
      self.compression = true
      self.action = :encode

      self.separator("Action")
      self.on("-e", "--encode",     "Whitespace encode file [Default]")          do self.action = :enocde           end
      self.on("-x", "--decode",    "Decode whitespace encoded file. The result is send to stdout") do
	                                                                            self.action = :decode           end
      self.on("-?", "-h", "--help", "This help")                                 do self.action = :show_help        end

      self.separator("Encoding")
      self.on("-s", "--simple",     "Simple encoding. [Default]")                do self.encoding = WhiteOutSimple  end
      self.on("-c", "--compact",    "Use compact encoding")                      do self.encoding = WhiteOutCompact end
      
      self.separator("Compression")
      self.on("-z", "--compress",   "Use additional zlib compression [Default]") do self.compression = true         end
      self.on("-n", "--nocompress", "Do not use additional zlib compression")    do self.compression = false        end
      

      self.parse!(args)
    end
  end

  options = WhiteOutOptions.new 
  case options.action
  when :show_help

    puts "Whitespace encode ruby files"
    puts
    puts "Usage:"
    puts "  whiteout [OPTIONS] File1 [Files...]"
    puts
    puts options
    puts
    puts "(c) 2005 Brian Schröder"
    puts "http://ruby.brian-schroeder.de/quiz/whiteout/"
    puts
    puts "This code is released under the GPL. Do as you like, but remember:"
    puts "  No warranty at all. This may kill all your files."
    
  when :encode

    ARGV.each do | infile |
      WhiteOutFileActions.encode_file(options.encoding, infile, options.compression)
    end

  when :decode
    
    ARGV.each do | infile |
      puts WhiteOutFileActions.decode_file(WhiteOutFileActions::ENCODERS, infile)
    end

  else

    throw "This is unexpected"
      
  end

else

  code = File.read($0).gsub(/^.*require "whiteout"/m, '')
  eval WhiteOutFileActions.decode_file(WhiteOutFileActions::ENCODERS, $0)

end
