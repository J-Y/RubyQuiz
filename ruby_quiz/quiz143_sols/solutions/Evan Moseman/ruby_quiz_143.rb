#!/usr/bin/ruby
# Author: Evan Moseman
# Ruby Quiz #143
# 10/12/2007

# Simple implementation to match the test, added a piece to also
# iterate through square brackets, in which is adds each character
# But, it won't do nested expressions, yet...
#
# >> /(lovely|delicious|splendid)(food|snacks|munchies)/.generate
# => ["lovelyfood", "lovelysnacks", "lovelymunchies",
#     "deliciousfood", "delicioussnacks", "deliciousmunchies",
#     "splendidfood", "splendidsnacks", "splendidmunchies"]

# >> /(a|b|c|d|e)_some_word [1234]/.generate
# => ["a_some_word 1", "a_some_word 2", "a_some_word 3",
#     "a_some_word 4", "b_some_word 1", "b_some_word 2",
#     "b_some_word 3", "b_some_word 4", "c_some_word 1",
#     "c_some_word 2", "c_some_word 3", "c_some_word 4",
#     "d_some_word 1", "d_some_word 2", "d_some_word 3",
#     "d_some_word 4", "e_some_word 1", "e_some_word 2",
#     "e_some_word 3", "e_some_word 4"]


class Regexp
  def generate
    queue = Array.new
    solution = Array.new
    queue << source

    while !queue.empty?
      step = queue.shift
      if step =~ /(\(([^\)]+)\))/
        target = $1
        $2.split("|").each do |p|
          new_string = step.sub("#{target}", p)
          queue.push new_string
        end
      elsif step =~ /(\[([^\]]+)\])/
        target = $1
        $2.scan(/./).each do |c|
          new_string = step.sub("#{target}", c)
          queue.push new_string
        end
      else
        solution << step
      end
    end
    return solution
  end
end