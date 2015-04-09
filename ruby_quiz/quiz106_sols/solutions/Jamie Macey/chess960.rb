class Chess960
 attr_reader :board_id, :board

 def initialize
   @board = generate_board(bodlaender_line)
 end

 def generate_board(white)
   # Black's starting line is mirror of white's
   black = white.map{|piece| piece.downcase}

   # middle of board is always the same
   middle = [
     %w(p p p p p p p p),
     %w(_ _ _ _ _ _ _ _),
     %w(_ _ _ _ _ _ _ _),
     %w(_ _ _ _ _ _ _ _),
     %w(_ _ _ _ _ _ _ _),
     %w(P P P P P P P P)
   ]

   # add back rows
   [black] + middle + [white]
 end

 def bodlaender_line
   free = (0...8).to_a
   white = []

   dark_bishop = rand(4) * 2
   light_bishop = rand(4) * 2 + 1
   white[dark_bishop] = 'B'
   white[light_bishop] = 'B'
   free.delete(dark_bishop)
   free.delete(light_bishop)

   queen = rand(6)
   white[free[queen]] = 'Q'
   free.delete_at(queen)

   knight1 = rand(5)
   white[free[knight1]] = 'N'
   free.delete_at(knight1)
   knight2 = rand(4)
   white[free[knight2]] = 'N'
   free.delete_at(knight2)

   white[free[0]] = 'R'
   white[free[1]] = 'K'
   white[free[2]] = 'R'
   white
 end
end
