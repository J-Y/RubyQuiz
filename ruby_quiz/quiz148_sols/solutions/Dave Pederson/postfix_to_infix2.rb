#!/usr/bin/env ruby

op = %w{ + - * / }
postfixes = ["2 3 5 + *",
             "1 56 35 + 16 9 - / +",
             "56 34 213.7 + * 678 -",
             "5 9 * 8 7 4 6 + * 2 1 3 * + * + *",
             "3 5 * 5 8 * /"]

postfixes.each do |postfix|
  stack = []
  postfix.split.each do |c|
    unless op.include? c
      stack.push(c)
    else
      second, first = stack.pop, stack.pop
      stack.push "( #{first} #{c} #{second} )"
    end
  end
  puts "postfix = #{postfix}"
  puts "infix = #{stack.pop}"
  puts
end
