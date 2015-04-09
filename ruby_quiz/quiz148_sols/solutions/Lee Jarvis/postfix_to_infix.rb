#!/usr/bin/ruby -w

argv = Array.new
if ARGV.empty?
  puts "#{$0} <Postfix equation>"
else
  ARGV.each do |a|
    if ['+', '-', '/', '*'].include?(a)
      last = argv.pop
      first = argv.pop
      argv << "(#{first} #{a} #{last})"
    else
      argv << a
    end
  end
  puts argv
end

