#!/usr/local/bin/ruby -w

require "strscan"

stack = Array.new
input = StringScanner.new(ARGF.read)

until input.eos?
  if input.scan(/[\[({]/)
    stack.push(input.matched)
  elsif input.scan(/[\])}]/)
    exit(1) unless "#{stack.pop}#{input.matched}" =~ /\A(?:\[\]|\(\)|\{\})\Z/
  else
    input.scan(/[^\[\](){}]+/)
  end
end
exit(1) unless stack.empty?

exit(1) if input.string =~ /\(\)|\[\]|\{\}/

puts input.string
