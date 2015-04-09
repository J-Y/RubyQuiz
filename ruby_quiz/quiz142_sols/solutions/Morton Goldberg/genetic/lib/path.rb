# lib/path.rb
# GA_Path
#
# Created by Morton Goldberg on September 18, 2007
#
# Models paths traversing a grid starting from and returning to the origin.
# Exposes an interface suitable for finding the shortest tour traversing
# the grid using a GA solver.

require "enumerator"

class Path
   attr_reader :ranking, :pts, :grid
   def initialize(grid)
      @grid = grid
      @order = grid.n**2
      @ranking = nil
      @pts = nil
   end
   def randomize
      pts = @grid.pts
      @pts = pts[1..-1].sort_by { rand }
      @pts.unshift(pts[0]).push(pts[0])
      rank
      self
   end
   def initialize_copy(original)
      @pts = original.pts.dup
   end
   def length
      len = 0.0
      @pts.each_cons(2) { |p1, p2| len += dist(p1, p2) }
      len
   end
   def inspect
      "#<#{self.class} length=#{length}, pts=#{@pts.inspect}>"
   end
   def to_s
      by_fives = @pts.enum_for(:each_slice, 5)
      "length: %.2f excess: %.2f\%\n" % [length, excess] +
      by_fives.collect do |row|
         row.collect { |pt| pt.inspect }.join('  ')
      end.join("\n")
   end
   def snapshot
      "length: %.2f excess: %.2f\%" % [length, excess]
   end
   # Relative difference between length and minimum length expressed as
   # percentage.
   def excess
      100.0 * (length / grid.min - 1.0)
   end
   def replicate
      replica = dup
      cuts = cut_at
      case cuts.size
      when 2
         replica.reverse(*cuts).rank if cuts[0] + 1 < cuts[1]
      when 3
         replica.exchange(*cuts).rank
      end
      replica
   end
protected
   # Recombination operator: reverse segment running from i to j - 1.
   def reverse(i, j)
      recombine do |len|
         (0...i).to_a + (i...j).to_a.reverse + (j...len).to_a
      end
   end
   # Recombination operator: exchange segment running from i to j - 1
   # with the one running from j to k - 1.
   def exchange(i, j, k)
      recombine do |len|
         (0...i).to_a + (j...k).to_a + (i...j).to_a + (k...len).to_a
      end
   end
   def rank
      @ranking = sum_dist_sq * dist_sq(*@pts.last(2))
      # Alternative fitness function
      # @ranking = sum_dist_sq
      # Alternative fitness function
      # @ranking = length
   end
private
   # Build new points array from list of permuted indexes.
   def recombine
      idxs = yield @pts.length
      @pts = idxs.inject([]) { |pts, i| pts << @pts[i] }
      self
   end
   # Sum of the squares of the distance between successive path points.
   def sum_dist_sq
      sum = 0.0
      @pts.each_cons(2) { |p1, p2| sum += dist_sq(p1, p2) }
      sum
   end
   # Find the points at which to apply the recombiation operators.
   # The argument allows for deterministic testing.
   def cut_at(seed=nil)
      srand(seed) if seed
      cuts = []
      3.times { cuts << 1 + rand(@order) }
      cuts.uniq.sort
   end
   # Square of the distance between points p1 and p2.
   def dist_sq(p1, p2)
      x1, y1 = p1
      x2, y2 = p2
      dx, dy = x2 - x1, y2 - y1
      dx * dx + dy * dy
   end
   # Distance between points p1 and p2.
   def dist(p1, p2)
      Math.sqrt(dist_sq(p1, p2))
   end
end
