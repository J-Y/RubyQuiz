class Chess960
 @@boards = []

 def boards
   @@boards
 end

 def initialize
   board = Board.new()
   (0..2).each do |lr|
     board << lr
     (lr+1..3).each do |k|
       board << k
       (k+1..7).each do |rr|
         board << rr
         board.free_.each do |q|
           board << q
           board.free_.find_all{|x| x.odd?}.each do |bb|
             board << bb
             board.free_.find_all{|x| x.even?}.each do |wb|
               board << wb
               @@boards << b = board.to_s
               @@boards << board.to_s.reverse
               board.pop
             end # white bishop
             board.pop
           end # black bishop
           board.pop
         end # queen
         board.pop
       end # right rook
       board.pop
     end # king
     board.pop
   end # left rook
   puts @@boards.length
 end


 def to_human(i)
   lrow = @@boards[i]
   lrow.downcase + "p" * 8 + "32" + "P" * 8 + lrow
 end

 def get_one
   i = rand(960)
   to_human(i)
 end

 def [](n)
   return @@boards[n]
 end

end

class Fixnum

 def odd?
   self % 2 == 0 ? false : true
 end

 def even?
   not(self.odd?)
 end

end



class Board

 attr_reader :free_, :position

 @@pieces = %w(R K R Q B B N N)

 def initialize()
   @position = []
   @free_ = (0..7).to_a - @position
 end

 def to_s
   order = "N" * 8
   @position.each_with_index do |p,i|
     order[p] = @@pieces[i]
   end
   return order
 end

 def <<(n)
   @position << n
   @free_ = @free_ - [n]
 end

 def pop
   @free_ << @position.pop
 end


end
