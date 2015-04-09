#!/usr/bin/ruby

class Chess960

 private_class_method :new

 @@all = []

 def Chess960.setup
     (0..959).each do |i|
       @@all << Board.new(i)
     end
   true
 end

 def Chess960.[](n)
   @@all[n]
 end

 def Chess960.random()
   self.get(rand(960)).to_s
 end

 # Position p is decomposed as
 # p =     96n + 16q + b with
 # (0..15) === b, (0..5) === q, and
 # (0..9) === n. See bottom for an
 # explanation

 class Board

   attr_reader :board

   def initialize(p)
     @board = Hash.new()
     bishop = p % 16
     nights = (p - (p % 96)) / 96
     queen = ((p % 96) - bishop) / 16
     @board = iposition(bishop, nights, queen)
   end

   def to_s
     return "[FEN " + board.join("").downcase + "/" + "p" * 8 +
              "/8/8/8/8/" + "P" * 8 + "/" + board.join("") + " w KQkq - 0 1]"
   end

   private

   def bishop(i)
     white = (i - (black = i % 4)) / 4
     return ([ (white * 2), black * 2 + 1])
   end

   def nights(i)
     case i
     when 9
       n1, n2 = 3, 4
     when 7,8
       n1, n2 = 2, 3 + (i % 7)
     else
       n1 = ( i - i % 3) / 3
       n2 = i % 3 + 1
     end
     return ([n1,n2])
   end

   def queen(i) # dummy but easier to understand
     return i
   end

   # see the explanation at bottom for this method's algorithm
   def iposition(b, n, q)
     base =  %w(R R R R R R)
     @board = %w(B B B B B B B B)
     # put the queen in its place in "all-but-bishops"
     base[queen(q)] = "Q"
     # put the knights in their place in "all-but-bishops"
     nights(n).each do |x|
       (x < queen(q) && base[x] = "N") or (base[x+1] = "N")
     end
     # place the King: substitute the middle Rook by a King
     # and finish (simpler than reading the code)
     king = false
     base.each_with_index do |p,i|
       (king == true and base[i] == "R" and base[i] = "K" and break)
       (p == "R" && king = true)
     end

     # and now put the bishops in place, ie: keeping the
     # bishops in their place, put all the other pieces
     # in their order
     minus = 0
     bish = bishop(b)
     (0..7).each do |i|
       if bish.include?(i)
         minus += 1
         next
       end
       @board[i] = base[i-minus]
     end
     return @board
   end

 end


 true
end


## explanation of p = 96n + 16q + b
##
## Bishops' position. Give the bottom squares (a1..h1)
## the following values:
##    0,0,4,1,8,2,12,3
## Any number b = 0..15 can be written uniquely as
##    b = wb + bb
## with wb in a white square and bb in a black one
## This gives bishops' table.
##
##
## Consider the six remaining pieces, and number a
## six-row from 0 to 5 from left to right:
##    0,1,2,3,4,5
##
## The position of the queen inside that row is q
##
## Finally, let the remaining five squares be numbered
##    0,1,2,3,4
##
## For the right knight, the values of each square are
##    -, 0, 1, 2, 3 (the first one does not count bc is
##                     never filled by the right one)
##
## For the left knight, the corresponding values are
##    0, 3, 5, 6, - (ibid.)
##
## Now every number (0..9) can be written uniquely as
##    ln + rn (left knight + right knight) using two
##         different position on the 5-row
##
## Place the rooks and king in the remaining three squares
## following the r-k-r rule and the board is built.
