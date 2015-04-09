#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-debug'

VERBOSE = ENV['VERBOSE'] || false

=begin
somelongstring
**---****---** max = 2
||   ****   **
     ||**   **
      ||    ** MATCH & done

banana
-***** max = 2
 ||*** MATCH
  ||** MATCH & done

|looking_for|*looking_in*

N(x) = x/2 + N(x-1)
O= n   -> 0,1,2,3, 4, 5, 6, 7, 8, 9, 10
O= ??? -> 0,1,2,4, 6, 9,12,16,20,23, 30
O= n^2 -> 0,1,4,9,16,25,36,49,64,81,100
=end

def find_duplicates(string)
  indexes = Array.new(string.length){|i|i}
  dups = indexes.map do |index|
    looking_in = string[(index+1)..-1]
    looking_in << string[0..(index-1)] unless index == 0
    looking_in.include?(string[index]) && string[index]
  end
  dups = dups.inject(['']) do |acc, char|
    if char
      acc.last << char
    else
      acc.push('')
    end
    acc
  end
  dups.select{|s| !s.empty?}
end
def find_longest_substring(strings)
  matches = []
  lengths = strings.map{|s|s.length}
  length = (lengths << lengths.max/2).sort.last
  while matches.empty? && length > 1

    strings.each_with_index do |string, index|
      0.upto(string.length-length) do |shift|
        looking_ins = strings.dup
        looking_for = looking_ins.delete_at(index)
        looking_ins.insert index, looking_for[shift+length..-1]
        looking_ins = looking_ins.select{|s| s.length >= length}
        looking_for = looking_for[(shift)..(shift+length-1)]
  
        looking_ins.map { |looking_in|
          puts "looking for:#{looking_for} in:#{looking_in}" if VERBOSE
          matches << ((looking_in.include?(looking_for) || nil) && looking_for)
        }
      end
    end
    matches = matches.compact.uniq
  
    return matches.join(', ') if matches.any?
    length -= 1
  end
  return nil
end

if __FILE__ == $0
  string = ARGV[0] || STDIN.gets
  string = string.match(/\s*([^\s]*)\s*/)[1]
  if string.nil? || string.empty?
    STDOUT << "Useage: #{__FILE__} some_string\n"
    STDOUT << "    or: echo some_string | #{__FILE__}\n"
  else
    duplicates = find_duplicates string
    puts duplicates.join(',') if VERBOSE
    STDOUT << find_longest_substring(duplicates) << "\n"
  end
end
