class Integer
   def even?
      self & 1 == 0
   end

   def maze_adj
      if even?
         [self + 2, self * 2, self / 2]
      else
         [self + 2, self * 2]
      end
   end
end


def solve(a, b)
   known = []

   i = 0
   steps = [[a]]
   known << a

   until steps[i].include?(b)
      i += 1
      steps[i] = []
      steps[i-1].each do |x|
         x.maze_adj.each { |y| steps[i] << y unless known.include?(y) }
      end
      known.concat steps[i]
   end

   i -= 1
   path = [b]
   i.downto(0) do |k|
      s = steps[k].find_all { |x| x.maze_adj.include? path.last }
      path << s.sort_by { rand }.first
   end

   path.reverse
end


# Examples
p solve(9, 2)
p solve(2, 9)
p solve(22, 99)
p solve(222, 999)
