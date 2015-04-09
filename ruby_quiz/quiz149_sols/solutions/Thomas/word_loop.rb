#!/usr/bin/env ruby
# Author::      Thomas Link (micathom AT gmail com)
# Created::     2007-12-08.

class Quiz149
   Solution = Struct.new(:idx, :width, :height)

   def initialize(word)
       @word      = word
       @wordic    = word.downcase
       @wordsize  = word.size
       @solutions = []
   end

   def find_solutions
       for height in 1 .. (@wordsize - 4)
           for width in 1 .. (@wordsize - 2 * height - 2)
               for idx in 0 .. (@wordsize - 2 * height - 2 * width - 1)
                   if @wordic[idx] == @wordic[idx + width * 2 + height * 2]
                       @solutions << Solution.new(idx, width, height)
                       return self # Remove this line to find all solutions
                   end
               end
           end
       end
       self
   end

   def print_solutions
       if @solutions.empty?
           puts 'No loop.'
           puts
       else
           @solutions.each_with_index do |sol, sol_idx|
               canvas_x = sol.idx + sol.width + 1
               canvas_y = @wordsize - sol.idx - sol.height - 2 * sol.width
               canvas   = Array.new(canvas_y) {' ' * canvas_x}
               pos_x    = -1
               pos_y    = canvas_y - sol.height - 1
               @word.scan(/./).each_with_index do |char, i|
                   if i <= sol.idx + sol.width
                       pos_x += 1
                   elsif i <= sol.idx + sol.width + sol.height
                       pos_y += 1
                   elsif i <= sol.idx + 2 * sol.width + sol.height
                       pos_x -= 1
                   else
                       pos_y -= 1
                   end
                   if canvas[pos_y][pos_x] == 32
                       canvas[pos_y][pos_x] = char
                   end
               end
               puts canvas.join("\n")
               puts
           end
       end
       self
   end

end


if __FILE__ == $0
   if ARGV.empty?
       Quiz149.new('Mississippi').find_solutions.print_solutions
       Quiz149.new('Markham').find_solutions.print_solutions
       Quiz149.new('yummy').find_solutions.print_solutions
       Quiz149.new('Dana').find_solutions.print_solutions
   else
       ARGV.each {|w| Quiz149.new(w).find_solutions.print_solutions}
   end
end
