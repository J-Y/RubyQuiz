class PenAndPaperGame
 MOVES = [[3,0], [-3,0], [0,3], [0,-3], [2,2], [2,-2], [-2,2], [-2,-2]]

 def initialize(size)
   @size = size
   @largest = @size * @size
   @board = Array.new(@size) { Array.new(@size) }
 end

 def to_s
   return "No solution." unless @board[0][0]
   digits = @largest.to_s.size
   " #{'-' * (digits+2) * @size}\n|" +
   (@board.map { |l| l.map{|e| " %#{digits}d " % e}.join }.join("|\n|")) +
   "|\n #{'-' * (digits+2) * @size}\n"
 end

 def solve
   @size.times { |x| @size.times { |y| return self if jump(1, x, y) } }
   self
 end

 private

 def valid(x, y)
   x >= 0 && x < @size && y >= 0 && y < @size && !@board[x][y]
 end

 def nb_exit(x, y)
   MOVES.inject(0) { |m, (i, j)| valid(x+i, y+j) ? m+1 : m }
 end

 def jump(nb, x, y)
   @board[x][y] = nb
   return true if nb == @largest
   MOVES.map { |i,j| [x+i, y+j] }.select { |i,j| valid(i,j) }.
     sort_by { |i,j| nb_exit(i,j) }.each { |i,j| return true if jump(nb+1, i, j) }
   @board[x][y] = nil
 end
end

if __FILE__ == $0
 size = (ARGV[0] || 5).to_i
 puts PenAndPaperGame.new(size).solve
end
