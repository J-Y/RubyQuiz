n = ARGV[0].to_i

# pass this method two coordinates relative to the center of the spiral
def spiral(x, y)
 max_xy = [x,y].collect{|num| num.abs}.max
 offset = (max_xy * 2 - 1)**2 - 1

 if -(x) == max_xy and x != y
   y + offset + max_xy
 elsif y == max_xy
   x + offset +  (3 * max_xy)
 elsif x == max_xy
   -y + offset + (5 * max_xy)
 elsif -(y) == max_xy
   -x + offset + (7 * max_xy)
 end
end

for row in 0..(n - 1)
 # the ease of writing one-liners in ruby lends itself to abuse...
 puts (0..(n - 1)).map{|col| spiral(col - (n / 2), (n / 2) -
row).to_s.rjust(4) }.join
end
