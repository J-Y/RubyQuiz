#!/usr/bin/env ruby

op = %w{ + - / * }
pm = %w{ + - }

postfixes = ["2 3 5 + *",
             "1 56 35 + 16 9 - / +",
             "56 34 213.7 + * 678 -",
             "5 9 * 8 7 4 6 + * 2 1 3 * + * + *"]

puts
postfixes.each do |postfix|
  stack = []
  postfix.split.each do |c|
    if op.include?(c)
      second, first = stack.pop, stack.pop
      if pm.include?(c)
        stack.push "(#{first} #{c} #{second})"
      else
        stack.push "#{first} #{c} #{second}"
      end
    else
      stack.push(c)
    end
  end
  infix = stack.pop
  if (infix[0] == 40 && infix[infix.size-1] == 41)
    infix = infix[1, infix.size-2]
  end
  puts "postfix = #{postfix}"
  puts "infix = #{infix}"
  puts
end
