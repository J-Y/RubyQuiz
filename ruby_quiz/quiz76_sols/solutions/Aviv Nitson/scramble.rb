#!/usr/bin/ruby

class Array
  def scramble
    a = self.dup
    a2 = []
    a.length.times do
      a2.push(a.slice!(rand(a.length)))
    end
    a2
  end
end

class String
  def scramble_middle
    self.gsub(/(\w+)/) do |word|
      if word.length > 2
        word.gsub(/(#{word[1..-2]})/) {$1.split(//).scramble.join('')}
      else
        word
      end
    end
  end
end

text = STDIN.gets
puts text.scramble_middle
