#!/usr/bin/env ruby -w

unless ARGV.size >= 1
  puts "Usage: wordloop.rb <string>"
  exit
end

require 'wordloop'

word = ARGV.shift
@wl = WordLoop.new(word)

if not @wl.duplicate_letters? or not @wl.has_loop?
  puts "No loop."
  exit
end

puts @wl.to_s