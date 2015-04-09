#!/bin/env ruby

class Fibonacci
   DIRS = [:left, :down, :right, :up]
     def initialize(num)
       @values = []
       Fibonacci.calc(num) { |x| @values << x }
   end

   def draw
       current_dir = 0
       main = nil
       @values.each do |v|
           next if 0 == v
           b = block_for(v)
           if ! main
               main = b
               next
           end
           main = add_block(main, b, DIRS[current_dir])
           current_dir = current_dir == 3 ? 0 : current_dir + 1
       end

       print_block(main)
   end

   # Linear Fibonacci calculation
   def Fibonacci.calc(num)
       prev, result = -1, 1
       (0..num).each do
           yield sum = result + prev
           prev = result
           result = sum
       end
   end

   private
   def block_for(num)
       return [] if num == 0

       top = []
       0.upto(num * 2) { top << "#" }
             middle = ["#"]
       2.upto(num * 2) { middle << " " }
       middle << "#"

       b = []
       b  << top
       2.upto(num * 2) { b << middle }
       b << top
   end

   def add_block(main, b, dir)
       if :left == dir
           return add_left(b, main)
       elsif :right == dir
           return add_left(main, b)
       elsif :down == dir
           return add_bottom(main, b)
       elsif :up == dir
           return add_bottom(b, main)
       end
   end

   def add_left(left, right)
       0.upto(left.length - 1) { |i| left[i] = left[i].slice(0..-2) + right[i] if right[i] }
       return left
   end

   def add_bottom(top, bottom)
       1.upto(bottom.length - 1) { |i| top << bottom[i] }
       return top
   end
     def print_block(b)
       b.each { |x| print x; print "\n" }
   end
end

if __FILE__ == $0
   0.upto(ARGV.length - 1) do |i|
       puts "Fibonacci for: " + ARGV[i]
       f = Fibonacci.new(ARGV[i].to_i)
       f.draw
       puts
   end
end
