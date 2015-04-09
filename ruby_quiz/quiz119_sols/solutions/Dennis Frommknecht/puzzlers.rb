#!/usr/bin/env ruby -W

# This solution uses 3 nested loops to divide the 
# numbers into 4 groups (using regular expressions). 
# Then the 3 allowed combinations of plus and minus
# are inserted between the groups.
# Finally the result is calculated using eval

NUMBERS = "123456789"
CORRECT_RES = 100
OPS = [['+', '-', '-'],
       ['-', '+', '-'],
       ['-', '-', '+']]

num_of_ops = OPS[0].length
equ_counter = 0

1.upto(NUMBERS.length - num_of_ops) do |i|
1.upto(NUMBERS.length - num_of_ops - i + 1) do |j|
1.upto(NUMBERS.length - num_of_ops - i + 1 - j + 1) do |k|
  if NUMBERS.match(/(\d{#{i}})(\d{#{j}})(\d{#{k}})(\d+)/) then
    OPS.each do |o|
      command = "#{$1} #{o[0]} #{$2} #{o[1]} #{$3} #{o[2]} #{$4}"
      res = eval command
      equ_counter += 1      
      puts "*" * 15 if res == CORRECT_RES
      puts "#{command} = #{res}"
      puts "*" * 15 if res == CORRECT_RES
    end
  end
end
end
end

puts "#{equ_counter} possible equations tested"
