#!/usr/local/bin/ruby -w

require 'lib/guitar'
require 'lib/tab'

Tab.new(ARGV[0]).parse

axe = Guitar.new
Tab.new(ARGV[0]).parse.each do |notes|
  axe.play(notes)
end
print axe.dump
