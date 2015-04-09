class Integer
   def pow2?
      (self & (self-1)).zero? and not self.zero?
   end

   def even?
      (self & 1).zero?
   end
end


class Array
   def reflect    # vertical
      self.reverse
   end

   def turn       # 90 deg CCW
      self.transpose.reflect
   end

   def fold       # top to bottom
      raise "Invalid fold." unless size.even?
      w, hh = self[0].size, size / 2
      above, below = self[0, hh].reverse, self[hh, hh]
      Array.new_2d(w,hh) { |r,c| above[r][c].reverse.concat below[r][c] }
   end

   def Array.new_2d(w, h)
      Array.new(h) do |r|
         Array.new(w) do |c|
            yield r, c
         end
      end
   end
end


def fold(w, h, cmds)
   raise "Bad dimensions: #{w}x#{h}" unless w.pow2? and h.pow2?
   paper = Array.new_2d(w, h) { |r,c| [w*r + c + 1] }

   cmds.each_byte do |cmd|
      case cmd
      when ?T
         paper = paper.fold
      when ?R
         paper = paper.turn.fold.turn.turn.turn
      when ?B
         paper = paper.turn.turn.fold.turn.turn
      when ?L
         paper = paper.turn.turn.turn.fold.turn
      end
   end

   raise "Not enough folds!" unless paper[0][0] == paper.flatten
   paper[0][0]
end
