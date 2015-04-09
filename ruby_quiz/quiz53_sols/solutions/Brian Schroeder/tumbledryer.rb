#!/usr/bin/ruby

require 'zlib'

puts %(require "zlib"),
     %(puts Zlib::Inflate.inflate(DATA.read)),
     "__END__",
     Zlib::Deflate.deflate(ARGF.read)
