#!/usr/bin/env ruby -w

class Array
  def rand
    fetch(Kernel.rand(size))
  end
end

characters         = %w[James Ruby]
sentence_structure = [ "S falls in love with O.",
                       "S (slays|kills) O(.|.|.|!)",
                       "S cries." ]

output = String.new
(ARGV.shift || 5).to_i.times do
  sentence = sentence_structure.rand.gsub(/\b[SO]\b/) { characters.rand }
  output << "  " << sentence.gsub(/\([^()|]+(?:\|[^()|]+)+\)/) do |choices|
    choices[1..-2].split("|").rand
  end
end

puts output.strip.gsub(/(.{1,80}|\S{81,})(?: +|$\n?)/, "\\1\n")
