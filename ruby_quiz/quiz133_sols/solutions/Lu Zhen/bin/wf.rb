#!/usr/bin/env ruby -wKU

require "word_filter"

if ARGV.size != 4
  puts "Usage: ruby -I bin:lib bin/wf.rb [Dictionary Location] [Base] [Number Limit] [Capitalized Words Filter]"
  puts "\t\t [Dictionary Location] is a string of the dictionary file path"
  puts "\t\t [Base] is a integer value"
  puts "\t\t [Number Limit] is a integer value"
  puts "\t\t [Capitalized Words Filter] is a boolean value"
else

  location = ARGV.shift
  base = (ARGV.shift || 16).to_i
  upper = (ARGV.shift || 0).to_i
  low = (ARGV.shift.eql?("true") || false)

  filter = WordFilter.new(base, upper, low)

  File.open(location) do |file|
    while line = file.gets
      if line.downcase[0] >= (base - 10 + 97)
        break
      end
      word = line.clone
      if filter.pick(line)
        puts word
      end
    end
  end
end