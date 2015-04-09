class Board
   def initialize(n)
       @w = 2**n;
       @tiles = Array.new(4**n, '0')
   end
     # Solve a board indicating row and column of the missing tile
     def solve(xm, ym)
       @count = 0
       @tiles[getPos(xm, ym)] = 'X'
       solve_r(0, 0, xm, ym, @w)
   end
     # n: position of the tromino (upper left corner)
   # miss: tile shouldn't be marked
   # code: character writed in each position, but in miss.
     def setTromino(n, miss, code)
       [0, 1, @w, @w+1].each { |i|
           @tiles[n+i] = code if miss!=n+i
       }
   end

   #
   # Transform coordinates
   #
   def getPos(i, j)
       return i*@w+j
   end

   # Warning: this is too slow (Why?)
   # Avoid this method in benchmarks

   def to_s
       cad = ''
       @tiles.each_index { |i|
           cad += @tiles[i] + ' '
           cad += "\n" if i%@w==@w-1
       }
       return cad
   end
     private
=begin
   This is a Divide and Conquer solution.
   Base case: 2x2 board. Solution is trivial in this case
     0 X
   0 0
     General case: NxN board. We solve the 4 subboards following this scheme:
     p.e: 4x4
     0 0 0 X
   0 S 0 0
   0 S S 0
   0 0 0 0
     We solve 4 2x2 boards.
   If the selected tile X is in the subboard, we solve it normally.
   If not, we solve supossing selected tiles are the marked as S.
   Finally, in the place of S, we put another tromino, and the board is solved.
=end
   def solve_r(x0, y0, xm, ym, n)
       if(n==2)
           setTromino(getPos(x0, y0), getPos(xm, ym), @count.to_s)
           @count += 1
           return
       end
       n/=2
       s = [] # Position for missing tile in the S tromino
       [[0, 0], [0, n], [n, 0], [n, n]].each { |d|
           # (x1, y1): upper left corner of the subboard
           # (dx, dy): position of S in the subboard
           x1, y1, dx, dy = x0+d[0], y0+d[1], x0+(d[0]==0 ? n-1:n), y0+(d[1]==0 ? n-1:n)
           if((x1...x1+n).include?(xm) && (y1...y1+n).include?(ym))
               s = [dx, dy]
               solve_r(x1, y1, xm, ym, n)
           else
               solve_r(x1, y1, dx, dy, n)
           end
       }
             setTromino(getPos(x0+n-1, y0+n-1), getPos(s[0], s[1]), @count.to_s)
       @count += 1
   end

end

if ARGV.length == 2
   b = Board.new(3)
   b.solve(ARGV[0].to_i, ARGV[1].to_i)
   puts b.to_s
end
