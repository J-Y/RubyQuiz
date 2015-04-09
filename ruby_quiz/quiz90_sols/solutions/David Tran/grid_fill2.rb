class PenAndPaperGame2
 MOVES = [[3,0], [-3,0], [0,3], [0,-3], [2,2], [2,-2], [-2,2], [-2,-2]]
 attr_reader :found

 def initialize(size)
   @size = size
   @board = Array.new(@size) { Array.new(@size) }
   @found = false
 end

 def to_s
   return "No soultion" unless @found
   digits = (@size * @size).to_s.size
   " #{'-' * (digits+2) * @size}\n|" +
   (@board.map { |l| l.map{|e| " %#{digits}d " % e}.join }.join("|\n|")) +
   "|\n #{'-' * (digits+2) * @size}\n"
 end

 def solve
   half = (@size - 1) / 2 + 1
   half.times do |x|
     half.times do |y|
       @head = 1
       @tail = @size * @size
       cc = head(nil, @head, x, y)
       if cc
         tail(cc, @tail, *next_pos(x, y))
       end
       return self if @found
     end
   end
   self
 end

 private

 def valid?(x, y)
   x >= 0 && x < @size && y >= 0 && y < @size && !@board[x][y]
 end

 def nb_exit(x, y)
   MOVES.inject(0) { |m, (i, j)| valid?(x+i, y+j) ? m+1 : m }
 end

 def next_pos(x, y)
   MOVES.map { |i,j| [x+i, y+j] }.
     select  { |i,j| valid?(i, j) }.
     sort_by { |i,j| nb_exit(i, j)} [0]
 end

 def head(tail, nb, x, y=nil)
   @head = nb
   @found = true if @head >= @tail
   return if @found || !x
   @board[x][y] = nb
   tail = callcc { |cc|
     return cc if !tail
     tail.call cc
   }
   head(tail, nb+1, *next_pos(x, y))
 end

 def tail(head, nb, x, y=nil)
   @tail = nb
   @found = true if @head >= @tail
   return if @found || !x
   @board[x][y] = nb
   head = callcc { |cc|
     head.call cc
   }
   tail(head, nb-1, *next_pos(x, y))
 end

end

if __FILE__ == $0
 size = (ARGV[0] || 5).to_i
 puts PenAndPaperGame2.new(size).solve
end
