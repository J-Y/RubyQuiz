#!/usr/bin/env ruby

if ! ARGV[0]
  puts "Usage: munge.rb filename.txt"
else
  infile = File.open(ARGV[0])
  infile.map do |line|
    line.split.map do |word|
      if word =~ /\W$/
        punctuation = word[-1..-1]
        word.chop!
      else
        punctuation = ""
      end
      if word.length > 3
        inner = word[1...-1]
        word = word[0..0] + inner.split(//).sort_by {rand}.join('') + word[-1..-1] + punctuation
      end
      print word + " "
    end
    puts
  end
end
