#!/usr/bin/ruby
#
# Whiteout
#
# A response to Ruby Quiz of the Week #34 [ruby-talk:144452]
#
# Run as an application, like so:
#
#   ruby whiteout.rb file_to_encode.rb [...]
#
# Whiteout encodes the given ruby scripts in-place in whiteout code. That is,
# these scripts become invisible. (Backups are made, as file_to_encode.rb.bak)
# These invisible whiteout scripts can be run normally with Ruby as long as
# whiteout is in the require path.
#
# You can also require it as a library:
# 
#   require 'whiteout'
#
# In this mode, Whiteout will interpret the current script as whiteout code
# and execute it.
#
# Inspiration credit is given to NegaPosi by SASADA Koichi <ko1@atdot.net>,
# which this started from. Although I'm not sure there's even a single byte
# of it left, its heart remains.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 3 Jun 2005
#
# Last modified: 3 Jun 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.

module Whiteout
  
  SHEBANG = /\A#!.*\n/
  REQUIRE = "require 'whiteout'\n"
  
  def encode ruby_code
    r = []
    ruby_code.scan(SHEBANG)[0].to_s +
    REQUIRE +
    (ruby_code.sub(SHEBANG, "") + "\0").scan(/.{1,8}/m).map do |line|
      line.unpack("b*")[0].split(//).map do |bit|
        (bit.to_i * 23 + 9).chr
      end.join
    end.join($/)
  end
  
  def decode whiteout_code
    whiteout_code.
    sub(SHEBANG, "").sub(REQUIRE, "").
    scan(/ |\t/).join.scan(/.{8}/).map do |c|
      [c.unpack("c*").map do |bit|
        (bit - 9) / 23
      end.join].pack("b*")
    end.join
  end

  extend self
end

if __FILE__ == $0
  a = ARGV.uniq.select {|f| File.exists? f }
  if a.empty?
    puts "usage: ruby whiteout.rb file_to_encode.rb [...]"
    puts "Encode given files in-place in whiteout code."
    puts "Encoded files can be run with Ruby if whiteout is in require's path."
  else
    a.each do |f|
      b = "#{f}.bak"
      File.delete b if File.exists? b
      File.rename f, b
      File.open(f, "w") do |f|
        f.puts Whiteout.encode(File.read(b))
      end
    end
  end
else
  eval "$0 = __FILE__; #{ Whiteout.decode(File.read($0)) }"
end
