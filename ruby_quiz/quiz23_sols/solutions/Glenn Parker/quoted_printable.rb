#!/usr/bin/env ruby -w

require 'getoptlong'

MaxLength = 76

def main
  opts = GetoptLong.new(
    [ "-d", GetoptLong::NO_ARGUMENT ],
    [ "-x", GetoptLong::NO_ARGUMENT ]
  )
  $opt_decode = false
  $opt_xml = false
  opts.each do |opt, arg|
    case opt
    when "-d": $opt_decode = true
    when "-x": $opt_xml = true
    end
  end

  if $opt_decode
    decode_input
  else
    encode_input
  end
end

def encode_input
  STDOUT.binmode  # We need to control the line-endings.
  while (line = gets) do
    # Note: String#chomp! swallows more than just $/.
    line.sub!(/#{$/}$/o, "")
    # Encode the entire line.
    line.gsub!(/[^\t -<>-~]+/) { |str| encode_str(str) }
    line.gsub!(/[&<>]+/)       { |str| encode_str(str) } if $opt_xml
    line.sub!(/\s*$/)          { |str| encode_str(str) }
    # Split the line up as needed.
    while line.length > MaxLength
      ### original code ###
      # split = line.index("=", MaxLength - 4) - 1
      # split = (MaxLength - 2) if split.nil? or (split > MaxLength - 2)
	  ### BUGFIX:  index() can return nil, so don't subtract -JEG2 ###
      split = line.index("=", MaxLength - 4)
      split = (MaxLength - 2) if split.nil? or (split - 1 > MaxLength - 2)
      print line[0..split], "=\r\n"
      line = line[(split + 1)..-1]
    end
    print line, "\r\n"
  end
end

def encode_str(str)
  encoded = ""
  str.each_byte { |c| encoded << "=%02X" % c }
  encoded
end

def decode_input
  while (line = gets) do
    line.chomp!
    line.gsub!(/=([\dA-F]{2})/) { $1.hex.chr }
    if line[-1] == ?=
      print line[0..-2]
    else
      print line, $/
    end
  end
end

main
