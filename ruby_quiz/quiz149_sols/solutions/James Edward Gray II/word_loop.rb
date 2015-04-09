#!/usr/bin/env ruby -wKU

word = ARGV.first or abort "Usage:  #{File.basename($PROGRAM_NAME)} WORD"
if word.downcase =~ /([a-z]).(?:.{2})+\1/
  before, during, after = word[0,          $`.length],
                          word[$`.length,  $&.length],
                          word[-$'.length, $'.length]
  indent                = " " * before.length
  after.split("").reverse_each { |char| puts indent + char }
  puts before + during[0..1]
  ((during.length - 3) / 2).times do |i|
    puts indent + during[-(i + 2), 1] + during[2 + i, 1]
  end
else
  puts "No loop."
end
