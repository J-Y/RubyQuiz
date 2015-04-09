#!/usr/bin/ruby


#
# This is my solution for Ruby Quiz #34, Whiteout.
# Author::  Robin Stocker
#


#
# The Whiteout module includes all functionality like:
# - whiten
# - run
# - encode
# - decode
#
module Whiteout

  @@bit_to_code = { '0' => " ", '1' => "\t" }
  @@code_to_bit = @@bit_to_code.invert
  @@chars_to_ignore = [ "\n", "\r" ]

  #
  # Whitens the content of a file specified by _filename_.
  # It leaves the shebang intact, if there is one.
  # At the beginning of the file it inserts the require 'whiteout'.
  # See #encode for details about how the whitening works.
  #
  def Whiteout.whiten( filename )
    code = ''
    File.open( filename, 'r' ) do |file|
      file.each_line do |line|
        if code.empty?
          # Add shebang if there is one.
          code << line if line =~ /#!\s*.+/
          code << "#{$/}require 'whiteout'#{$/}"
        else
          code << encode( line )
        end
      end
    end
    File.open( filename, 'w' ) do |file|
      file.write( code )
    end
  end

  #
  # Reads the file _filename_, decodes and runs it through eval.
  #
  def Whiteout.run( filename )
    text = ''
    File.open( filename, 'r' ) do |file|
      decode = false
      file.each_line do |line|
        if not decode
          # We don't want to decode the "require 'whiteout'",
          # so start decoding not before we passed it.
          decode = true if line =~ /require 'whiteout'/
        else
          text << decode( line )
        end
      end
    end
    # Run the code!
    eval text
  end

  #
  # Encodes text to "whitecode". It works like this:
  # - Chars in @@char_to_ignore are ignored
  # - Each byte is converted to its bit representation,
  #   so that we have something like 01100001
  # - Then, it is converted to whitespace according to @@bit_to_code
  # - 0 results in a " " (space)
  # - 1 results in a "\t" (tab)
  #
  def Whiteout.encode( text )
    white = ''
    text.scan(/./m) do |char|
      if @@chars_to_ignore.include?( char )
        white << char
      else
        char.unpack('B8').first.scan(/./) do |bit|
          code = @@bit_to_code[bit]
          white << code
        end
      end
    end
    return white
  end

  #
  # Does the inverse of #encode, it takes "white"
  # and returns the decoded text.
  #
  def Whiteout.decode( white )
    text = ''
    char = ''
    white.scan(/./m) do |code|
      if @@chars_to_ignore.include?( code )
        text << code
      else
        char << @@code_to_bit[code]
        if char.length == 8
          text << [char].pack("B8")
          char = ''
        end
      end
    end
    return text
  end

end


#
# And here's the logic part of whiteout.
# If it was run directly, whites out the files in ARGV.
# And if it was required, decodes the whitecode and runs it.
#
if __FILE__ == $0
  ARGV.each do |filename|
    Whiteout.whiten( filename )
  end
else
  Whiteout.run( $0 )
end
