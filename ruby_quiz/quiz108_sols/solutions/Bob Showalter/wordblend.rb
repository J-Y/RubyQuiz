# wordblend.rb
# simplistic Word Blend puzzle game
# uses puzzles.dat file created by separate puzzles.rb program

class String
 def rot13
   tr 'A-Za-z', 'N-ZA-Mn-za-m'
 end
end

class Puzzle

 attr_reader :words, :letters, :board

 def self.pick
   @@puzzles ||= IO.readlines('puzzles.dat')
   new(@@puzzles[rand(@@puzzles.size)].chomp.rot13.split(':'))
 end

 def initialize(words)
   @words = words
   scramble
   @board = words.collect {|w| w.gsub(/./, '-')}
 end

 def scramble
   @letters = words.last.split(//).sort_by {rand}.join
   scramble if words.include? @letters
 end

 def help
   puts "Enter 'Q' to give up, 'S' to scramble letters"
 end

 def play
   help
   turn while board != words
   puts board
 end

 def turn
   puts board
   puts
   puts letters
   while true
     print "? "
     guess = gets.strip.upcase
     if guess == ''
       help
       redo
     end
     if guess == 'S'
       scramble
       puts letters
       redo
     end
     @board = words.dup if guess == 'Q'
     i = words.index(guess) and board[i] = guess
     break
   end
 end

end

# play a random game
p = Puzzle.pick
p.play
