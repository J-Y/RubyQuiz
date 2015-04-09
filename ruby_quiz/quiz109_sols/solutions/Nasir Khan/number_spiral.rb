class Array
  def cnext
   @p ||= -1
   @p += 1
   @p = 0 if @p == self.length
   self[@p]
  end
end


class ClockState
 def initialize
   @seq = [:left, :up, :right, :down]
   @count = 1
   @count_state = 0
   @times = 0
   @val = @seq.cnext
 end

 def next
   if @count == @count_state
     @val = @seq.cnext
     @count_state = 0
     @times += 1
     if @times == 2
       @count += 1
       @times = 0
     end
   end
   @count_state += 1
   @val
 end
end




class Spiral
 def initialize(dim)
   @m = []
   dim.times do
     @m << Array.new(dim, 0)
   end
   @x = dim/2
   @y = dim/2
   @val = 0
   @sz = dim
 end

 def left
   @x -= 1
 end

 def up
   @y -= 1
 end

 def right
   @x += 1
 end

 def down
   @y +=1
 end

 def make_spiral dir_hash={:dir=>:clock}
   c = ClockState.new
   while ((@x < @sz) && (@y < @sz))
     if dir_hash[:dir]==:counter
       @m[@x][@y] = @val
     elsif dir_hash[:dir]==:clock
       @m[@y][@x] = @val
     else
       raise "Legal values are :clock and :counter"
     end
     self.send(c.next)
     @val += 1
   end
 end

 def print_spiral
   fmt_sz = (@sz*@sz).to_s.length + 2
   for i in 0...@sz do
     print "\n"
     for j in 0...@sz do
       printf("%#{fmt_sz}d", @m[i][j])
     end
   end
 end
end

s = Spiral.new(20)
s.make_spiral :dir=>:clock
s.print_spiral
