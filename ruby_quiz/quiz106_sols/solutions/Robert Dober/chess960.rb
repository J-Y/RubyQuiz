#!/usr/bin/ruby
class Chess960
   class ::Range
       class << self
           def free= args
               @@free = args
           end
       end
       def each_free
           each do
               |ele|
               next unless @@free.include? ele
               @@free.delete ele
               yield ele
               @@free.unshift ele
           end
       end #def each_free
   end

   N = 8
   def initialize
       @solutions = []
       Range.free = [*1..N]
       init
       generate
   end
   def [] sol_nb
       @solutions[ sol_nb ]
   end

   private
   def init
       @sol="Q " * N
   end
   def generate
       (1..N-1).each_free do
           |@b1|
           (@b1.succ..N).each_free do
               |@b2|
               next if @b1 & 1 == @b2 & 1
               (1..N-2).each_free do
                   |@r1|
                   (@r1.succ..N-1).each_free do
                       |@k|
                       (@k.succ..N).each_free do
                           |@r2|
                           (1..N-1).each_free do
                               |@n1|
                               (@n1.succ..N).each_free do
                                   |@n2|
                                   save_solution
                               end
                           end
                       end #(@k.succ..N).each_free do
                   end
               end #(1..N-2).each_free do
           end
       end
   end
   def save_solution
       @sol[2*(@b1-1)]= ?B
       @sol[2*(@b2-1)]= ?B
       @sol[2*(@r1-1)]= ?R
       @sol[2*(@r2-1)]= ?R
       @sol[2*(@n1-1)]= ?N
       @sol[2*(@n2-1)]= ?N
       @sol[2*(@k-1)] = ?K

       @solutions << @sol
       init
   end

end

c = Chess960.new
puts %<enter a number to show a specific solution (0 based) or
enter r for a random solution or
enter q to go back to work>
until (n = gets.strip) =~ /^q/i
   i = n.to_i
   i = rand(960) if n =~ /^r/i
   puts "Solution #{i}"
   puts c[i]
end
