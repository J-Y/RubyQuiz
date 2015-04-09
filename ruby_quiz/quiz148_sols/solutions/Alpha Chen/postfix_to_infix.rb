#!/usr/bin/env ruby

str = ARGV[0].split(/[^.\d+\-*\/]/).join(' ')

while str !~ /^\(.*\)$/
  str.sub!(/([^ ]+) ([^ ]+) ([+\-*\/])/, '(\1\3\2)')
end

puts str.gsub(/([+\-*\/])/, ' \1 ').sub(/^\((.*)\)$/, '\1')
